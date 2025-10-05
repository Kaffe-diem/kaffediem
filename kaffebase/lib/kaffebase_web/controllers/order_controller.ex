defmodule KaffebaseWeb.OrderController do
  use KaffebaseWeb, :controller
  require Logger

  alias Kaffebase.Orders
  alias KaffebaseWeb.{ControllerHelpers, PBSerializer, ParamParser}

  action_fallback KaffebaseWeb.FallbackController

  def index(conn, params) do
    sort = ParamParser.parse_sort(params["sort"])
    filters = ParamParser.parse_order_filters(params["filter"])

    opts =
      filters
      |> Keyword.put(:order_by, default_order(sort))

    orders = Orders.list_orders(opts)
    meta = ParamParser.pagination(params, length(orders))
    response = Map.put(meta, :items, PBSerializer.resource(orders))
    json(conn, response)
  end

  def create(conn, params) do
    attrs = ControllerHelpers.atomize_keys(params)
    Logger.info("Creating order via HTTP: #{inspect(Map.keys(attrs))}")

    with {:ok, order} <- Orders.create_order(attrs) do
      Logger.info("Order created via HTTP: #{order.id}")
      conn
      |> put_status(:created)
      |> json(PBSerializer.resource(order))
    end
  end

  def show(conn, %{"id" => id}) do
    order = Orders.get_order!(id)
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
end
