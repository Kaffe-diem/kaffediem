defmodule KaffebaseWeb.CategoryController do
  use KaffebaseWeb, :controller

  alias Kaffebase.Catalog

  action_fallback KaffebaseWeb.FallbackController

  def index(conn, _params) do
    categories = Catalog.list_categories()
    json(conn, categories)
  end

  def create(conn, params) do
    with {:ok, category} <- Catalog.create_category(params) do
      conn
      |> put_status(:created)
      |> json(category)
    end
  end

  def show(conn, %{"id" => id}) do
    category = Catalog.get_category!(id)
    json(conn, category)
  end

  def update(conn, %{"id" => id} = params) do
    category = Catalog.get_category!(id)
    attrs = Map.delete(params, "id")

    with {:ok, category} <- Catalog.update_category(category, attrs) do
      json(conn, category)
    end
  end

  def delete(conn, %{"id" => id}) do
    category = Catalog.get_category!(id)

    with {:ok, _} <- Catalog.delete_category(category) do
      send_resp(conn, :no_content, "")
    end
  end
end
