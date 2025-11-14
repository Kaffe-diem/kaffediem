defmodule KaffebaseWeb.OrderController do
  use KaffebaseWeb, :controller
  require Logger

  alias Kaffebase.Orders

  action_fallback KaffebaseWeb.FallbackController

  def index(conn, params) do
    from_date = params["from_date"]
    customer_id = params["customer_id"]

    opts =
      [order_by: default_order()]
      |> then(fn o -> if from_date, do: Keyword.put(o, :from_date, from_date), else: o end)
      |> then(fn o -> if customer_id, do: Keyword.put(o, :customer, customer_id), else: o end)

    orders = Orders.list_orders(opts)
    json(conn, orders)
  end

  def create(conn, params) do
    Logger.info("HTTP API: Creating order with params: #{inspect(Map.keys(params))}")

    with {:ok, order} <- Orders.create_order(params) do
      Logger.info("HTTP API: Order created successfully: #{order.id}")

      conn
      |> put_status(:created)
      |> json(order)
    end
  end

  def show(conn, %{"id" => id}) do
    order = Orders.get_order!(id)
    json(conn, order)
  end

  def update(conn, %{"id" => id} = params) do
    order = Orders.get_order!(id)
    attrs = Map.delete(params, "id")

    with {:ok, order} <- Orders.update_order(order, attrs) do
      json(conn, order)
    end
  end

  def delete(conn, %{"id" => id}) do
    order = Orders.get_order!(id)

    with {:ok, _} <- Orders.delete_order(order) do
      send_resp(conn, :no_content, "")
    end
  end

  defp default_order, do: [asc: :day_id, asc: :inserted_at]
end
