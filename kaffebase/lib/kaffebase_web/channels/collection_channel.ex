defmodule KaffebaseWeb.CollectionChannel do
  use Phoenix.Channel

  alias Kaffebase.{Catalog, Content, Orders}
  alias KaffebaseWeb.{PBSerializer, ParamParser}

  @impl true
  def join("collection:" <> collection, payload, socket) do
    options = Map.get(payload, "options", %{})
    items = load_collection(collection, options)

    response = %{
      "items" => PBSerializer.resource(items),
      "page" => 1,
      "perPage" => length(items),
      "totalItems" => length(items),
      "totalPages" => 1
    }

    {:ok, response, socket}
  end

  @impl true
  def handle_in(_event, _payload, socket) do
    {:noreply, socket}
  end

  def broadcast_change(collection, action, record) do
    payload = %{
      "action" => action,
      "record" => PBSerializer.resource(record)
    }

    topic = "collection:" <> collection
    KaffebaseWeb.Endpoint.broadcast(topic, "change", payload)
  end

  def broadcast_delete(collection, record_id) do
    payload = %{
      "action" => "delete",
      "record" => %{id: record_id}
    }

    topic = "collection:" <> collection
    KaffebaseWeb.Endpoint.broadcast(topic, "change", payload)
  end

  defp load_collection("category", options) do
    order = ParamParser.parse_sort(Map.get(options, "sort"))
    Catalog.list_categories(order_by: fallback_order(order, asc: :sort_order, asc: :name))
  end

  defp load_collection("item", options) do
    order = ParamParser.parse_sort(Map.get(options, "sort"))

    Catalog.list_items(
      order_by: fallback_order(order, asc: :sort_order, asc: :name),
      category: Map.get(options, "category") || Map.get(options, "category_id")
    )
  end

  defp load_collection("customization_key", options) do
    order = ParamParser.parse_sort(Map.get(options, "sort"))
    Catalog.list_customization_keys(order_by: fallback_order(order, asc: :sort_order, asc: :name))
  end

  defp load_collection("customization_value", options) do
    order = ParamParser.parse_sort(Map.get(options, "sort"))

    Catalog.list_customization_values(
      order_by: fallback_order(order, asc: :sort_order, asc: :name),
      belongs_to:
        Map.get(options, "belongs_to") || Map.get(options, "key") || Map.get(options, "key_id")
    )
  end

  defp load_collection("item_customization", options) do
    expand = ParamParser.parse_expand(Map.get(options, "expand"), item_customization_expand())
    Catalog.list_item_customizations(preload: expand)
  end

  defp load_collection("message", _options) do
    Content.list_messages()
  end

  defp load_collection("status", options) do
    expand = ParamParser.parse_expand(Map.get(options, "expand"), %{"message" => :message})
    Content.list_statuses(preload: expand)
  end

  defp load_collection("order", options) do
    filters = ParamParser.parse_order_filters(Map.get(options, "filter"))

    Orders.list_orders(
      Keyword.merge(filters,
        preload: [:items, :item_records, :customizations],
        order_by: [asc: :day_id, asc: :created]
      )
    )
  end

  defp load_collection(_other, _options), do: []

  defp fallback_order([], default), do: default
  defp fallback_order(order, _default), do: order

  defp item_customization_expand do
    %{
      "key" => :key,
      "key_expand" => :key,
      "value" => :values,
      "values" => :values
    }
  end
end
