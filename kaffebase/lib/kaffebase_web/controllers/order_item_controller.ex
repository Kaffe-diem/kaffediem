defmodule KaffebaseWeb.OrderItemController do
  use KaffebaseWeb, :controller

  alias Kaffebase.Orders

  action_fallback KaffebaseWeb.FallbackController

  def create(conn, params) do

    with {:ok, order_item} <- Orders.create_order_item(params) do
      conn
      |> put_status(:created)
      |> json(order_item)
    end
  end

  def show(conn, %{"id" => id}) do
    order_item = Orders.get_order_item!(id)
    json(conn, order_item)
  end

  def update(conn, %{"id" => id} = params) do
    order_item = Orders.get_order_item!(id)
    attrs = Map.delete(params, "id")

    with {:ok, order_item} <- Orders.update_order_item(order_item, attrs) do
      json(conn, order_item)
    end
  end

  def delete(conn, %{"id" => id}) do
    order_item = Orders.get_order_item!(id)

    with {:ok, _} <- Orders.delete_order_item(order_item) do
      send_resp(conn, :no_content, "")
    end
  end
end
