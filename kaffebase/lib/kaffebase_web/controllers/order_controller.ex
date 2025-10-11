defmodule KaffebaseWeb.OrderController do
  use KaffebaseWeb, :controller
  require Logger

  alias Kaffebase.Orders
  alias KaffebaseWeb.{ControllerHelpers, DomainJSON}

  action_fallback KaffebaseWeb.FallbackController

  def index(conn, params) do
    opts =
      []
      |> maybe_put(:from_date, params["from"] || params["from_date"])
      |> maybe_put(:customer, params["customer_id"] || params["customer"])
      |> Keyword.put(:order_by, default_order())

    orders = Orders.list_orders(opts)
    json(conn, DomainJSON.render(orders))
  end

  def create(conn, params) do
    attrs = ControllerHelpers.atomize_keys(params)
    Logger.info("Creating order via HTTP: #{inspect(Map.keys(attrs))}")

    with {:ok, order} <- Orders.create_order(attrs) do
      Logger.info("Order created via HTTP: #{order.id}")

      conn
      |> put_status(:created)
      |> json(DomainJSON.render(order))
    end
  end

  def show(conn, %{"id" => id}) do
    order = Orders.get_order!(id)
    json(conn, DomainJSON.render(order))
  end

  def update(conn, %{"id" => id} = params) do
    order = Orders.get_order!(id)
    attrs = ControllerHelpers.atomize_keys(Map.delete(params, "id"))

    with {:ok, order} <- Orders.update_order(order, attrs) do
      json(conn, DomainJSON.render(order))
    end
  end

  def delete(conn, %{"id" => id}) do
    order = Orders.get_order!(id)

    with {:ok, _} <- Orders.delete_order(order) do
      send_resp(conn, :no_content, "")
    end
  end

  defp default_order, do: [asc: :day_id, asc: :created]

  defp maybe_put(opts, _key, nil), do: opts
  defp maybe_put(opts, key, value), do: Keyword.put(opts, key, value)
end
