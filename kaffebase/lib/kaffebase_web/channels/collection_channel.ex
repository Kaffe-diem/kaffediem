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

  alias Kaffebase.{Content, Orders}

  @impl true
  def join("collection:" <> collection, payload, socket) do
    options = Map.get(payload, "options", %{})
    Logger.info("Client joining collection:#{collection} with options: #{inspect(options)}")

    items = load_collection(collection, options)
    Logger.info("Loaded #{length(items)} items for collection:#{collection}")

    response = %{
      "items" => items,
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
      "record" => record
    }

    topic = "collection:" <> collection
    Logger.info("Broadcasting #{action} to #{topic}")

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

  defp load_collection("category", _options) do
    Crud.list(Category)
  end

  defp load_collection("item", options) do
    category_id = option(options, "category") || option(options, "category_id")
    opts = build_filter_opts(:category, category_id)
    Crud.list(Item, opts)
  end

  defp load_collection("customization_key", _options) do
    Crud.list(CustomizationKey)
  end

  defp load_collection("customization_value", options) do
    belongs_to =
      option(options, "belongs_to") ||
        option(options, "key") ||
        option(options, "key_id")

    opts = build_filter_opts(:belongs_to, belongs_to)
    Crud.list(CustomizationValue, opts)
  end

  defp load_collection("menu", _options) do
    categories = Crud.list(Category)
    items = Crud.list(Item)
    keys = Crud.list(CustomizationKey)
    values = Crud.list(CustomizationValue)

    # Group items by category
    items_by_category = Enum.group_by(items, & &1.category)

    # Group values by key
    values_by_key = Enum.group_by(values, & &1.belongs_to)

    # Build category → items → customizations hierarchy
    Enum.map(categories, fn category ->
      category_items =
        items_by_category
        |> Map.get(category.id, [])
        |> Enum.map(fn item ->
          # Find customization keys valid for this category
          valid_key_ids = category.valid_customizations || []

          customizations =
            Enum.filter(keys, fn key -> key.id in valid_key_ids end)
            |> Enum.map(fn key ->
              %{
                key: key,
                values: Map.get(values_by_key, key.id, [])
              }
            end)

          Map.merge(item, %{customizations: customizations})
        end)

      Map.merge(category, %{items: category_items})
    end)
  end

  defp load_collection("status", _options) do
    statuses = Content.list_statuses()
    messages = Content.list_messages()

    %{
      statuses: statuses,
      messages: messages
    }
  end

  # Legacy endpoints - keep for backwards compatibility during transition
  defp load_collection("message", _options) do
    Content.list_messages()
  end

  defp load_collection("order", options) do
    opts =
      []
      |> maybe_put(:from_date, option(options, "from") || option(options, "from_date"))
      |> maybe_put(:customer, option(options, "customer_id") || option(options, "customer"))
      |> Keyword.put(:order_by, asc: :day_id, asc: :inserted_at)

    Orders.list_orders(opts)
  end

  defp load_collection(_other, _options), do: []

  defp option(options, key) when is_binary(key) do
    case safe_atom(key) do
      nil -> Map.get(options, key)
      atom -> Map.get(options, key) || Map.get(options, atom)
    end
  end

  defp option(options, key) when is_atom(key) do
    Map.get(options, key) || Map.get(options, Atom.to_string(key))
  end

  defp option(_options, _key), do: nil

  defp safe_atom(key) do
    String.to_existing_atom(key)
  rescue
    ArgumentError -> nil
  end

  defp maybe_put(opts, _key, nil), do: opts
  defp maybe_put(opts, key, value), do: Keyword.put(opts, key, value)

  defp build_filter_opts(_field, nil), do: []
  defp build_filter_opts(field, value), do: [filter: {field, value}]
end
