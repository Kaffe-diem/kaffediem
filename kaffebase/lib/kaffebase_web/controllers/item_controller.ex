defmodule KaffebaseWeb.ItemController do
  use KaffebaseWeb, :controller

  alias Kaffebase.Catalog

  action_fallback KaffebaseWeb.FallbackController

  def index(conn, params) do
    category_id = params["category"] || params["category_id"]

    items =
      Catalog.list_items(category: category_id)

    json(conn, items)
  end

  def create(conn, params) do

    with {:ok, item} <- Catalog.create_item(params) do
      conn
      |> put_status(:created)
      |> json(item)
    end
  end

  def show(conn, %{"id" => id}) do
    item = Catalog.get_item!(id)
    json(conn, item)
  end

  def update(conn, %{"id" => id} = params) do
    item = Catalog.get_item!(id)
    attrs = Map.delete(params, "id")

    with {:ok, item} <- Catalog.update_item(item, attrs) do
      json(conn, item)
    end
  end

  def delete(conn, %{"id" => id}) do
    item = Catalog.get_item!(id)

    with {:ok, _} <- Catalog.delete_item(item) do
      send_resp(conn, :no_content, "")
    end
  end
end
