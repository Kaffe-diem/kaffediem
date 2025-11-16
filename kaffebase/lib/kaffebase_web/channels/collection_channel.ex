defmodule KaffebaseWeb.CollectionChannel do
  use Phoenix.Channel
  require Logger

  alias Kaffebase.Catalog.{
    Category,
    CustomizationKey,
    CustomizationValue,
    Item,
    Crud
  }

  alias Kaffebase.{Content, Orders, Repo}

  @impl true
  def join("collection:" <> collection, payload, socket) do
    options = Map.get(payload, "options", %{})
    Logger.info("Client joining collection:#{collection} with options: #{inspect(options)}")

    data = load_collection(collection, options)
    response = %{"items" => data}

    {:ok, response, socket}
  end

  @impl true
  def handle_in(_event, _payload, socket) do
    {:noreply, socket}
  end

  def broadcast_change(collection, action, record) do
    payload = %{
      "action" => action,
      "record" => record
    }

    topic = "collection:" <> collection
    Logger.info("Broadcasting #{action} to #{topic}")

    KaffebaseWeb.Endpoint.broadcast(topic, "change", payload)
  end

  def broadcast_delete(collection, record) do
    payload = %{
      "action" => "delete",
      "record" => %{id: record.id}
    }

    topic = "collection:" <> collection
    KaffebaseWeb.Endpoint.broadcast(topic, "change", payload)
  end

  def load_menu do
    load_collection("menu", %{})
  end

  defp load_collection("menu", _options) do
    categories = Crud.list(Category)
    items = Crud.list(Item) |> Repo.preload(:category)
    keys = Crud.list(CustomizationKey)
    values = Crud.list(CustomizationValue)

    items_by_category = Enum.group_by(items, & &1.category_id)
    values_by_key = Enum.group_by(values, & &1.belongs_to)

    tree =
      Enum.map(categories, fn category ->
        valid_key_ids = category.valid_customizations || []

        category_items =
          Map.get(items_by_category, category.id, [])
          |> Enum.map(fn item ->
            customizations =
              keys
              |> Enum.filter(&(&1.id in valid_key_ids))
              |> Enum.map(fn key ->
                %{
                  key: key,
                  values: Map.get(values_by_key, key.id, [])
                }
              end)

            Map.put(item, :customizations, customizations)
          end)

        Map.put(category, :items, category_items)
      end)

    customizations_by_key =
      Map.new(keys, fn key ->
        {key.id, Map.get(values_by_key, key.id, [])}
      end)

    %{
      tree: tree,
      indexes: %{
        categories: categories,
        items: items,
        items_by_category: items_by_category,
        customization_keys: keys,
        customization_values: values,
        customizations_by_key: customizations_by_key
      }
    }
  end

  defp load_collection("status", _options) do
    Content.list_statuses()
  end

  defp load_collection("message", _options) do
    Content.list_messages()
  end

  defp load_collection("order", options) do
    opts = [order_by: [asc: :day_id, asc: :inserted_at]]

    opts =
      if from_date = options["from_date"],
        do: Keyword.put(opts, :from_date, from_date),
        else: opts

    opts =
      if customer_id = options["customer_id"],
        do: Keyword.put(opts, :customer, customer_id),
        else: opts

    Orders.list_orders(opts)
  end

  # Unknown collections return empty list - client will get empty "items" response
  defp load_collection(_other, _options), do: []
end
