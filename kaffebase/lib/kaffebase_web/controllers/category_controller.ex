defmodule KaffebaseWeb.CategoryController do
  use KaffebaseWeb, :controller

  alias Kaffebase.Catalog
  alias KaffebaseWeb.{ControllerHelpers, DomainJSON}

  action_fallback KaffebaseWeb.FallbackController

  def index(conn, _params) do
    categories = Catalog.list_categories()
    json(conn, DomainJSON.render(categories))
  end

  def create(conn, params) do
    attrs = ControllerHelpers.atomize_keys(params)

    with {:ok, category} <- Catalog.create_category(attrs) do
      conn
      |> put_status(:created)
      |> json(DomainJSON.render(category))
    end
  end

  def show(conn, %{"id" => id}) do
    category = Catalog.get_category!(id)
    json(conn, DomainJSON.render(category))
  end

  def update(conn, %{"id" => id} = params) do
    category = Catalog.get_category!(id)
    attrs = ControllerHelpers.atomize_keys(Map.delete(params, "id"))

    with {:ok, category} <- Catalog.update_category(category, attrs) do
      json(conn, DomainJSON.render(category))
    end
  end

  def delete(conn, %{"id" => id}) do
    category = Catalog.get_category!(id)

    with {:ok, _} <- Catalog.delete_category(category) do
      send_resp(conn, :no_content, "")
    end
  end
end
