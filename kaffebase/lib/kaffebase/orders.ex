defmodule Kaffebase.Orders do
  @moduledoc """
  Orders context providing PocketBase-compatible data access helpers.
  """

  require Logger
  import Ecto.Query, warn: false

  alias Ecto.{Changeset, Multi}
  alias Kaffebase.Catalog
  alias Kaffebase.Catalog.{Item, ItemCustomization}
  alias Kaffebase.CollectionNotifier
  alias Kaffebase.Orders.Commands.PlaceOrder
  alias Kaffebase.Orders.DayId
  alias Kaffebase.Orders.Param
  alias Kaffebase.Orders.{Order, OrderItem}
  alias Kaffebase.Repo

  @type preload_option :: :items | :item_records | :customizations

  @spec list_orders(keyword()) :: [Order.t()]
  def list_orders(opts \\ []) do
    Order
    |> maybe_filter_from_date(opts[:from_date])
    |> maybe_filter(:customer, opts[:customer_id] || opts[:customer])
    |> maybe_apply_order(opts[:order_by] || [asc: :day_id, asc: :created])
    |> Repo.all()
    |> preload_all_items()
  end

  @spec get_order!(String.t(), keyword()) :: Order.t()
  def get_order!(id, _opts \\ []) do
    Order
    |> Repo.get!(id)
    |> preload_all_items()
  end

  @spec create_order(map()) :: {:ok, Order.t()} | {:error, term()}
  def create_order(attrs) when is_map(attrs) do
    with {:ok, command} <- PlaceOrder.new(attrs) do
      Multi.new()
      |> Multi.run(:order_items, fn repo, _ -> create_order_items(repo, command.items) end)
      |> Multi.run(:day_id, fn repo, _ -> next_day_id(repo) end)
      |> Multi.run(:order, fn repo, %{order_items: order_items, day_id: day_id} ->
        order_attrs = %{
          customer: command.customer_id,
          day_id: day_id,
          missing_information: command.missing_information,
          items: Enum.map(order_items, & &1.id),
          state: command.state
        }

        %Order{}
        |> Order.changeset(order_attrs)
        |> repo.insert()
      end)
      |> Repo.transaction()
      |> case do
        {:ok, %{order: order}} ->
          Logger.info("Order created: #{order.id}, day_id: #{order.day_id}")
          complete_order = preload_all_items(order)

          items_count = complete_order |> Map.get(:expand, %{}) |> Map.get(:items, []) |> length()
          Logger.info("Preloaded #{items_count} items for order #{order.id}")

          broadcast_change("order", "create", complete_order)
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
    # Only include items if explicitly provided to avoid overwriting with empty list
    items_value = Param.attr(attrs, :items, Param.attr(attrs, :item_ids))

    prepared_attrs =
      %{}
      |> maybe_put(:customer, attrs |> Param.attr(:customer) |> Param.extract_record_id())
      |> maybe_put(:missing_information, Param.attr(attrs, :missing_information))
      |> maybe_put(:items, items_value && Param.normalize_id_list(items_value))
      |> Map.put(:state, Param.cast_state(Param.attr(attrs, :state, order.state)))

    order
    |> Order.changeset(prepared_attrs)
    |> Repo.update()
    |> notify("order", "update")
  end

  @spec update_order_state(Order.t() | String.t(), Order.state()) ::
          {:ok, Order.t()} | {:error, Ecto.Changeset.t()}
  def update_order_state(%Order{} = order, state) do
    order
    |> Order.changeset(%{state: Param.cast_state(state)})
    |> Repo.update()
    |> notify("order", "update")
  end

  def update_order_state(order_id, state) when is_binary(order_id) do
    order_id
    |> Repo.get!(Order)
    |> update_order_state(state)
  end

  @spec set_all_orders_state(Order.state()) :: {non_neg_integer(), nil | [term()]}
  def set_all_orders_state(state) do
    new_state = Param.cast_state(state)
    {count, _} = Repo.update_all(Order, set: [state: new_state])

    Order
    |> Repo.all()
    |> preload_all_items()
    |> Enum.each(&broadcast_change("order", "update", &1))

    {count, nil}
  end

  @spec delete_order(Order.t()) :: {:ok, Order.t()} | {:error, Ecto.Changeset.t()}
  def delete_order(%Order{} = order) do
    order
    |> Repo.delete()
    |> notify_delete("order")
  end

  @spec get_order_item!(String.t()) :: OrderItem.t()
  def get_order_item!(id), do: Repo.get!(OrderItem, id)

  @spec create_order_item(map()) :: {:ok, OrderItem.t()} | {:error, Ecto.Changeset.t()}
  def create_order_item(attrs) do
    %OrderItem{}
    |> OrderItem.changeset(attrs)
    |> Repo.insert()
    |> notify("order_item", "create")
  end

  @spec update_order_item(OrderItem.t(), map()) ::
          {:ok, OrderItem.t()} | {:error, Ecto.Changeset.t()}
  def update_order_item(%OrderItem{} = order_item, attrs) do
    order_item
    |> OrderItem.changeset(attrs)
    |> Repo.update()
    |> notify("order_item", "update")
  end

  @spec delete_order_item(OrderItem.t()) :: {:ok, OrderItem.t()} | {:error, Ecto.Changeset.t()}
  def delete_order_item(%OrderItem{} = order_item) do
    order_item
    |> Repo.delete()
    |> notify_delete("order_item")
  end

  # --------------------------------------------------------------------------
  # Internal helpers

  defp maybe_put(map, _key, nil), do: map
  defp maybe_put(map, key, value), do: Map.put(map, key, value)
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
    with {:ok, date} <- Date.from_iso8601(date_string) do
      maybe_filter_from_date(query, date)
    else
      _ -> query
    end
  end

  defp maybe_apply_order(query, nil), do: query
  defp maybe_apply_order(query, []), do: query

  defp maybe_apply_order(query, orderings) when is_list(orderings) do
    order_by(query, ^orderings)
  end

  # Always load complete order data with items and their details
  defp preload_all_items(orders) when is_list(orders) do
    attach_order_items(orders, preload: [:items, :item_records, :customizations])
  end

  defp preload_all_items(order) do
    attach_order_items([order], preload: [:items, :item_records, :customizations]) |> List.first()
  end

  defp preload?(opts, target) do
    preloads = opts |> Keyword.get(:preload, []) |> List.wrap()

    Enum.member?(preloads, target) or Enum.member?(preloads, :all) or
      Enum.member?(preloads, :full)
  end

  defp attach_order_items([], _opts), do: []

  defp attach_order_items(orders, opts) do
    order_item_map = fetch_order_item_map(orders)

    orders
    |> Enum.map(fn order ->
      items =
        order.items
        |> Enum.map(&Map.get(order_item_map, &1))
        |> Enum.reject(&is_nil/1)
        |> maybe_attach_item_records(opts)
        |> maybe_attach_customizations(opts)

      expand = Map.get(order, :expand, %{}) |> Map.put(:items, items)
      Map.put(order, :expand, expand)
    end)
  end

  defp fetch_order_item_map(orders) do
    ids = orders |> Enum.flat_map(& &1.items) |> Enum.uniq()

    if ids == [] do
      %{}
    else
      OrderItem
      |> where([oi], oi.id in ^ids)
      |> Repo.all()
      |> Map.new(&{&1.id, &1})
    end
  end

  defp maybe_attach_item_records(items, opts) do
    if preload?(opts, :item_records) do
      item_map = fetch_item_map(items)

      Enum.map(items, fn item ->
        expand = Map.get(item, :expand, %{}) |> Map.put(:item, Map.get(item_map, item.item))
        Map.put(item, :expand, expand)
      end)
    else
      items
    end
  end

  defp fetch_item_map(items) do
    ids = items |> Enum.map(& &1.item) |> Enum.reject(&is_nil/1) |> Enum.uniq()

    if ids == [] do
      %{}
    else
      Item
      |> where([i], i.id in ^ids)
      |> Repo.all()
      |> Map.new(&{&1.id, &1})
    end
  end

  defp maybe_attach_customizations(items, opts) do
    if preload?(opts, :customizations) do
      customization_map = fetch_customization_map(items)

      Enum.map(items, fn item ->
        customizations =
          item.customization
          |> Enum.map(&Map.get(customization_map, &1))
          |> Enum.reject(&is_nil/1)

        expand = Map.get(item, :expand, %{}) |> Map.put(:customization, customizations)
        Map.put(item, :expand, expand)
      end)
    else
      items
    end
  end

  defp fetch_customization_map(items) do
    ids =
      items
      |> Enum.flat_map(& &1.customization)
      |> Enum.uniq()

    if ids == [] do
      %{}
    else
      Catalog.list_item_customizations_by_ids(ids, preload: [:key, :values])
      |> Map.new(&{&1.id, &1})
    end
  end

  defp create_order_items(repo, items) when is_list(items) do
    items
    |> Enum.reduce_while({:ok, []}, fn
      %PlaceOrder.Item{} = item, {:ok, acc} ->
        cond do
          PlaceOrder.Item.existing?(item) ->
            case Repo.get(OrderItem, item.existing_order_item_id) do
              %OrderItem{} = order_item -> {:cont, {:ok, [order_item | acc]}}
              nil -> {:halt, {:error, :invalid_order_item_reference}}
            end

          PlaceOrder.Item.new?(item) ->
            with {:ok, order_item} <- insert_order_item(repo, item) do
              {:cont, {:ok, [order_item | acc]}}
            else
              {:error, reason} -> {:halt, {:error, reason}}
            end

          true ->
            {:halt, {:error, :invalid_order_item}}
        end

      other, {:ok, _acc} ->
        Logger.warning("Discarding unexpected order item payload: #{inspect(other)}")
        {:halt, {:error, :invalid_order_item}}
    end)
    |> case do
      {:ok, order_items} -> {:ok, Enum.reverse(order_items)}
      other -> other
    end
  end

  defp insert_order_item(repo, %PlaceOrder.Item{} = item) do
    %OrderItem{}
    |> OrderItem.changeset(%{item: item.item_id})
    |> repo.insert()
    |> case do
      {:ok, order_item} ->
        broadcast_change("order_item", "create", order_item)

        with {:ok, customization_ids} <-
               maybe_create_item_customizations(repo, item.customizations) do
          update_with_customizations(repo, order_item, customization_ids)
        end

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  defp maybe_create_item_customizations(_repo, []), do: {:ok, []}

  defp maybe_create_item_customizations(repo, customizations) do
    customizations
    |> Enum.reduce_while({:ok, []}, fn customization, {:ok, acc} ->
      attrs = %{key: customization.key_id, value: customization.value_ids}

      %ItemCustomization{}
      |> ItemCustomization.changeset(attrs)
      |> repo.insert()
      |> case do
        {:ok, customization} ->
          broadcast_change("item_customization", "create", customization)
          {:cont, {:ok, [customization.id | acc]}}

        {:error, changeset} ->
          {:halt, {:error, changeset}}
      end
    end)
    |> case do
      {:ok, ids} -> {:ok, Enum.reverse(ids)}
      other -> other
    end
  end

  defp update_with_customizations(_repo, order_item, []), do: {:ok, order_item}

  defp update_with_customizations(repo, order_item, customization_ids) do
    order_item
    |> OrderItem.changeset(%{customization: customization_ids})
    |> repo.update()
    |> case do
      {:ok, updated} ->
        broadcast_change("order_item", "update", updated)
        {:ok, updated}

      other ->
        other
    end
  end

  defp notify({:ok, record} = result, "order", action) do
    Logger.info("Order #{action}: #{record.id}")
    complete = preload_all_items(record)

    items_count = complete |> Map.get(:expand, %{}) |> Map.get(:items, []) |> length()
    Logger.info("Preloaded #{items_count} items for order #{record.id}")

    broadcast_change("order", action, complete)
    Logger.info("Broadcast order #{action} for #{record.id}")
    result
  end

  defp notify({:ok, record} = result, collection, action) do
    broadcast_change(collection, action, record)
    result
  end

  defp notify(result, _collection, _action), do: result

  defp notify_delete({:ok, record} = result, collection) do
    broadcast_delete(collection, record.id)
    result
  end

  defp notify_delete(result, _collection), do: result

  defp broadcast_change(collection, action, record) do
    Logger.debug("Broadcasting #{collection} #{action} to collection notifier")
    CollectionNotifier.broadcast_change(collection, action, record)
  end

  defp broadcast_delete(collection, id) do
    CollectionNotifier.broadcast_delete(collection, id)
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
