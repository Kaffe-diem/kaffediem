defmodule KaffebaseWeb.CategoryController do
  use KaffebaseWeb, :controller

  alias Kaffebase.Catalog.{Category, Crud}
  action_fallback KaffebaseWeb.FallbackController

  def index(conn, _params) do
    categories = Crud.list(Category)
    json(conn, categories)
  end

  def create(conn, params) do
    with {:ok, category} <- Crud.create(Category, params) do
      conn
      |> put_status(:created)
      |> json(category)
    end
  end

  def show(conn, %{"id" => id}) do
    category = Crud.get!(Category, id)
    json(conn, category)
  end

  def update(conn, %{"id" => id} = params) do
    category = Crud.get!(Category, id)
    attrs = Map.delete(params, "id")

    with {:ok, category} <- Crud.update(Category, category, attrs) do
      json(conn, category)
    end
  end

  def delete(conn, %{"id" => id}) do
    category = Crud.get!(Category, id)

    with {:ok, _} <- Crud.delete(Category, category) do
      send_resp(conn, :no_content, "")
    end
  end
end
