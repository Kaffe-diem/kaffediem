defmodule KaffebaseWeb.CollectionChannel do
  use Phoenix.Channel
  require Logger

  alias Kaffebase.{Catalog, Content, Orders}

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
    Catalog.list_categories()
  end

  defp load_collection("item", options) do
    Catalog.list_items(category: option(options, "category") || option(options, "category_id"))
  end

  defp load_collection("customization_key", _options) do
    Catalog.list_customization_keys()
  end

  defp load_collection("customization_value", options) do
    Catalog.list_customization_values(
      belongs_to:
        option(options, "belongs_to") ||
          option(options, "key") ||
          option(options, "key_id")
    )
  end

  defp load_collection("item_customization", _options) do
    Catalog.list_item_customizations()
  end

  defp load_collection("message", _options) do
    Content.list_messages()
  end

  defp load_collection("status", _options) do
    Content.list_statuses()
  end

  defp load_collection("order", options) do
    opts =
      []
      |> maybe_put(:from_date, option(options, "from") || option(options, "from_date"))
      |> maybe_put(:customer, option(options, "customer_id") || option(options, "customer"))
      |> Keyword.put(:order_by, asc: :day_id, asc: :created)

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
end
