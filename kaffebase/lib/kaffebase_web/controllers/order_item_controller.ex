defmodule KaffebaseWeb.OrderItemController do
  use KaffebaseWeb, :controller

  alias Kaffebase.Orders
  alias KaffebaseWeb.{ControllerHelpers, DomainJSON}

  action_fallback KaffebaseWeb.FallbackController

  def create(conn, params) do
    attrs = ControllerHelpers.atomize_keys(params)

    with {:ok, order_item} <- Orders.create_order_item(attrs) do
      conn
      |> put_status(:created)
      |> json(DomainJSON.render(order_item))
    end
  end

  def show(conn, %{"id" => id}) do
    order_item = Orders.get_order_item!(id)
    json(conn, DomainJSON.render(order_item))
  end

  def update(conn, %{"id" => id} = params) do
    order_item = Orders.get_order_item!(id)
    attrs = ControllerHelpers.atomize_keys(Map.delete(params, "id"))

    with {:ok, order_item} <- Orders.update_order_item(order_item, attrs) do
      json(conn, DomainJSON.render(order_item))
    end
  end

  def delete(conn, %{"id" => id}) do
    order_item = Orders.get_order_item!(id)

    with {:ok, _} <- Orders.delete_order_item(order_item) do
      send_resp(conn, :no_content, "")
    end
  end
end
