defmodule Kaffebase.Orders do
  @moduledoc """
  Phoenix context representing orders in the system
  """

  require Logger
  import Ecto.Query, warn: false

  alias Ecto.{Changeset, Multi}
  alias Kaffebase.Catalog.{Crud, CustomizationKey}
  alias Kaffebase.Orders.PlaceOrder
  alias Kaffebase.Orders.DayId
  alias Kaffebase.Orders.Order
  alias Kaffebase.Repo
  alias KaffebaseWeb.CollectionChannel

  @spec list_orders(keyword()) :: [Order.t()]
  def list_orders(opts \\ []) do
    Order
    |> maybe_filter_from_date(opts[:from_date])
    |> maybe_filter(:customer_id, opts[:customer_id] || opts[:customer])
    |> maybe_apply_order(opts[:order_by] || [asc: :day_id, asc: :inserted_at])
    |> Repo.all()
    |> Enum.map(&enrich_order_with_colors/1)
  end

  @spec get_order!(String.t(), keyword()) :: Order.t()
  def get_order!(id, _opts \\ []) do
    Order
    |> Repo.get!(id)
    |> enrich_order_with_colors()
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
      |> Repo.transaction()
      |> case do
        {:ok, %{order: order}} ->
          enriched_order = enrich_order_with_colors(order)
          Logger.info("Order created: #{enriched_order.id}, day_id: #{enriched_order.day_id}")
          broadcast_change("order", "create", enriched_order)
          {:ok, enriched_order}

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
    update_order(order, %{state: state})
  end

  def update_order_state(order_id, state) when is_binary(order_id) do
    order_id
    |> get_order!()
    |> update_order_state(state)
  end

  @spec set_all_orders_state(Order.state()) :: {non_neg_integer(), nil | [term()]}
  def set_all_orders_state(state) do
    {count, _} = Repo.update_all(Order, set: [state: state])

    Order
    |> Repo.all()
    |> Enum.map(&enrich_order_with_colors/1)
    |> Enum.each(&broadcast_change("order", "update", &1))

    {count, nil}
  end

  @spec delete_order(Order.t()) :: {:ok, Order.t()} | {:error, Ecto.Changeset.t()}
  def delete_order(%Order{} = order) do
    order
    |> Repo.delete()
    |> notify("order", "delete")
  end

  # --------------------------------------------------------------------------
  # Order enrichment

  defp enrich_order_with_colors(%Order{items: nil} = order), do: order

  defp enrich_order_with_colors(%Order{items: items} = order) when is_list(items) do
    keys = Crud.list(CustomizationKey) |> Map.new(& {&1.id, &1.label_color})

    enriched_items =
      Enum.map(items, fn item ->
        enriched_customizations =
          item
          |> Map.get("customizations", [])
          |> Enum.map(fn cust ->
            key_id = Map.get(cust, "key_id")
            label_color = Map.get(keys, key_id)
            Map.put(cust, "label_color", label_color)
          end)

        Map.put(item, "customizations", enriched_customizations)
      end)

    %{order | items: enriched_items}
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

  defp maybe_filter_from_date(query, "today") do
    maybe_filter_from_date(query, Date.utc_today())
  end

  defp maybe_filter_from_date(query, %Date{} = date) do
    {:ok, datetime} = DateTime.new(date, ~T[00:00:00], "Etc/UTC")
    where(query, [q], q.inserted_at >= ^datetime)
  end

  defp maybe_filter_from_date(query, _invalid), do: query

  defp maybe_apply_order(query, nil), do: query
  defp maybe_apply_order(query, []), do: query

  defp maybe_apply_order(query, orderings) when is_list(orderings) do
    order_by(query, ^orderings)
  end

  defp notify({:ok, record} = result, "order", action) do
    enriched_record = enrich_order_with_colors(record)
    items_count = length(enriched_record.items || [])
    Logger.info("Order #{action}: #{enriched_record.id} (#{items_count} items)")

    broadcast_change("order", action, enriched_record)
    result
  end

  defp notify({:ok, record} = result, collection, action) do
    broadcast_change(collection, action, record)
    result
  end

  defp notify(result, _collection, _action), do: result

  defp broadcast_change(collection, action, record) do
    CollectionChannel.broadcast_change(collection, action, record)
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
