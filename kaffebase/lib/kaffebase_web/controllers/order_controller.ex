defmodule KaffebaseWeb.OrderController do
  use KaffebaseWeb, :controller

  alias Kaffebase.Orders
  alias KaffebaseWeb.{ControllerHelpers, PBSerializer, ParamParser}

  action_fallback KaffebaseWeb.FallbackController

  @expand_mapping %{
    "items" => :items,
    "items.item" => :item_records,
    "items.customization" => :customizations,
    "items.customization.key" => :customizations,
    "items.customization.value" => :customizations
  }

  def index(conn, params) do
    expand = ParamParser.parse_expand(params["expand"], @expand_mapping)
    sort = ParamParser.parse_sort(params["sort"])
    filters = ParamParser.parse_order_filters(params["filter"])

    opts =
      filters
      |> Keyword.merge(preload: normalize_expand(expand))
      |> Keyword.put(:order_by, default_order(sort))

    orders = Orders.list_orders(opts)
    meta = ParamParser.pagination(params, length(orders))
    response = Map.put(meta, :items, PBSerializer.resource(orders))
    json(conn, response)
  end

  def create(conn, params) do
    attrs = ControllerHelpers.atomize_keys(params)

    with {:ok, order} <- Orders.create_order(attrs) do
      conn
      |> put_status(:created)
      |> json(PBSerializer.resource(order))
    end
  end

  def show(conn, %{"id" => id} = params) do
    expand = ParamParser.parse_expand(params["expand"], @expand_mapping)

    order = Orders.get_order!(id, preload: normalize_expand(expand))
    json(conn, PBSerializer.resource(order))
  end

  def update(conn, %{"id" => id} = params) do
    order = Orders.get_order!(id)
    attrs = ControllerHelpers.atomize_keys(Map.delete(params, "id"))

    with {:ok, order} <- Orders.update_order(order, attrs) do
      json(conn, PBSerializer.resource(order))
    end
  end

  def delete(conn, %{"id" => id}) do
    order = Orders.get_order!(id)

    with {:ok, _} <- Orders.delete_order(order) do
      send_resp(conn, :no_content, "")
    end
  end

  defp default_order([]), do: [asc: :day_id, asc: :created]
  defp default_order(order), do: order

  defp normalize_expand(expand) do
    expand
    |> Enum.reduce([], fn
      :items, acc -> Enum.uniq([:items | acc])
      :item_records, acc -> Enum.uniq([:items, :item_records | acc])
      :customizations, acc -> Enum.uniq([:items, :customizations | acc])
      other, acc -> Enum.uniq([other | acc])
    end)
  end
end
