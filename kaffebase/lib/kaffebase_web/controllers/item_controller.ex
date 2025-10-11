defmodule KaffebaseWeb.ItemController do
  use KaffebaseWeb, :controller

  alias Kaffebase.Catalog
  alias KaffebaseWeb.{ControllerHelpers, DomainJSON}

  action_fallback KaffebaseWeb.FallbackController

  def index(conn, params) do
    category_id = params["category"] || params["category_id"]

    items =
      Catalog.list_items(category: category_id)

    json(conn, DomainJSON.render(items))
  end

  def create(conn, params) do
    attrs = ControllerHelpers.atomize_keys(params)

    with {:ok, item} <- Catalog.create_item(attrs) do
      conn
      |> put_status(:created)
      |> json(DomainJSON.render(item))
    end
  end

  def show(conn, %{"id" => id}) do
    item = Catalog.get_item!(id)
    json(conn, DomainJSON.render(item))
  end

  def update(conn, %{"id" => id} = params) do
    item = Catalog.get_item!(id)
    attrs = ControllerHelpers.atomize_keys(Map.delete(params, "id"))

    with {:ok, item} <- Catalog.update_item(item, attrs) do
      json(conn, DomainJSON.render(item))
    end
  end

  def delete(conn, %{"id" => id}) do
    item = Catalog.get_item!(id)

    with {:ok, _} <- Catalog.delete_item(item) do
      send_resp(conn, :no_content, "")
    end
  end
end
