defmodule Kaffebase.Orders do
  @moduledoc """
  Orders context providing PocketBase-compatible data access helpers.
  """

  require Logger
  import Ecto.Query, warn: false

  alias Ecto.{Changeset, Multi}
  alias Kaffebase.CollectionNotifier
  alias Kaffebase.Orders.PlaceOrder
  alias Kaffebase.Orders.DayId
  alias Kaffebase.Orders.Event
  alias Kaffebase.Orders.Events
  alias Kaffebase.Orders.Process
  alias Kaffebase.Orders.OrderSupervisor
  alias Kaffebase.Orders.Order
  alias Kaffebase.Repo

  @spec list_orders(keyword()) :: [Order.t()]
  def list_orders(opts \\ []) do
    Order
    |> maybe_filter_from_date(opts[:from_date])
    |> maybe_filter(:customer_id, opts[:customer_id] || opts[:customer])
    |> maybe_apply_order(opts[:order_by] || [asc: :day_id, asc: :created])
    |> Repo.all()
  end

  @spec get_order!(String.t(), keyword()) :: Order.t()
  def get_order!(id, _opts \\ []) do
    Repo.get!(Order, id)
  end

  @spec create_order(map()) :: {:ok, Order.t()} | {:error, term()}
  def create_order(attrs) when is_map(attrs) do
    with {:ok, command} <- PlaceOrder.new(attrs) do
      Multi.new()
      |> Multi.run(:day_id, fn repo, _ -> next_day_id(repo) end)
      |> Multi.run(:order, fn repo, %{day_id: day_id} ->
        order_attrs = %{
          customer_id: command.customer_id,
          day_id: day_id,
          missing_information: command.missing_information,
          items: command.items,
          state: command.state
        }

        %Order{}
        |> Order.changeset(order_attrs)
        |> repo.insert()
      end)
      |> Multi.run(:event, fn _repo, %{order: order} ->
        event = %Events.OrderPlaced{
          order_id: order.id,
          customer: order.customer_id,
          day_id: order.day_id,
          missing_information: order.missing_information,
          timestamp: DateTime.utc_now()
        }

        Event.append(order.id, event)
      end)
      |> Repo.transaction()
      |> case do
        {:ok, %{order: order}} ->
          Logger.info("Order created: #{order.id}, day_id: #{order.day_id}")

          {:ok, _pid} = OrderSupervisor.start_order(order.id)

          items_count = length(order.items)
          Logger.info("Order has #{items_count} items")

          broadcast_change("order", "create", order)
          Logger.info("Broadcast order create for #{order.id}")
          {:ok, order}

        {:error, _step, reason, _changes} ->
          Logger.error("Order creation failed: #{inspect(reason)}")
          {:error, coerce_order_error(reason)}
      end
    else
      {:error, %Ecto.Changeset{} = changeset} = error ->
        Logger.warning("Order payload invalid: #{inspect(changeset.errors)}")
        error

      {:error, reason} = error ->
        Logger.error("Order creation failed before transaction: #{inspect(reason)}")
        error
    end
  end

  @spec update_order(Order.t(), map()) :: {:ok, Order.t()} | {:error, Ecto.Changeset.t()}
  def update_order(%Order{} = order, attrs) do
    order
    |> Order.changeset(attrs)
    |> Repo.update()
    |> notify("order", "update")
  end

  @spec update_order_state(Order.t() | String.t(), Order.state()) ::
          {:ok, Order.t()} | {:error, Ecto.Changeset.t()}
  def update_order_state(%Order{} = order, state) do
    update_order_state(order.id, state)
  end

  def update_order_state(order_id, state) do
    OrderSupervisor.start_order(order_id)

    with {:ok, _state} <- Process.change_state(order_id, state) do
      order = Repo.get!(Order, order_id)
      {:ok, order}
    end
  end

  @spec set_all_orders_state(Order.state()) :: {non_neg_integer(), nil | [term()]}
  def set_all_orders_state(state) do
    {count, _} = Repo.update_all(Order, set: [state: state])

    Order
    |> Repo.all()
    |> Enum.each(&broadcast_change("order", "update", &1))

    {count, nil}
  end

  @spec delete_order(Order.t()) :: {:ok, Order.t()} | {:error, Ecto.Changeset.t()}
  def delete_order(%Order{} = order) do
    OrderSupervisor.start_order(order.id)

    with {:ok, _state} <- Process.delete_order(order.id) do
      {:ok, order}
    end
  end

  # --------------------------------------------------------------------------
  # Internal helpers

  defp coerce_order_error({:error, %Changeset{} = changeset}), do: changeset
  defp coerce_order_error(%Changeset{} = changeset), do: changeset

  defp coerce_order_error(reason) do
    %Order{}
    |> Changeset.change()
    |> Changeset.add_error(:items, error_message(reason))
  end

  defp error_message(:invalid_order_item_reference), do: "references unknown order item"
  defp error_message(:invalid_order_item), do: "contains an invalid order item"
  defp error_message(reason) when is_atom(reason), do: to_string(reason)
  defp error_message(reason), do: inspect(reason)

  defp maybe_filter(query, _field, nil), do: query

  defp maybe_filter(query, field, value) do
    where(query, [q], field(q, ^field) == ^value)
  end

  defp maybe_filter_from_date(query, nil), do: query

  defp maybe_filter_from_date(query, %Date{} = date) do
    {:ok, datetime} = DateTime.new(date, ~T[00:00:00], "Etc/UTC")
    where(query, [q], q.created >= ^datetime)
  end

  defp maybe_filter_from_date(query, %NaiveDateTime{} = naive) do
    datetime = DateTime.from_naive!(naive, "Etc/UTC")
    where(query, [q], q.created >= ^datetime)
  end

  defp maybe_filter_from_date(query, %DateTime{} = datetime) do
    where(query, [q], q.created >= ^datetime)
  end

  defp maybe_filter_from_date(query, date_string) when is_binary(date_string) do
    case Date.from_iso8601(date_string) do
      {:ok, date} -> maybe_filter_from_date(query, date)
      {:error, _} -> query
    end
  end

  defp maybe_filter_from_date(query, _), do: query

  defp maybe_apply_order(query, nil), do: query
  defp maybe_apply_order(query, []), do: query

  defp maybe_apply_order(query, orderings) when is_list(orderings) do
    order_by(query, ^orderings)
  end

  defp notify({:ok, record} = result, "order", action) do
    items_count = length(record.items)
    Logger.info("Order #{action}: #{record.id} (#{items_count} items)")

    broadcast_change("order", action, record)
    result
  end

  defp notify({:ok, record} = result, collection, action) do
    broadcast_change(collection, action, record)
    result
  end

  defp notify(result, _collection, _action), do: result

  defp broadcast_change(collection, action, record) do
    Logger.debug("Broadcasting #{collection} #{action} to collection notifier")
    CollectionNotifier.broadcast_change(collection, action, record)
  end

  defp next_day_id(repo) do
    case DayId.next(repo) do
      {:ok, value} ->
        {:ok, value}

      {:error, reason} = error ->
        Logger.error("Failed to compute next day_id: #{inspect(reason)}")
        error
    end
  end
end
