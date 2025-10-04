defmodule KaffebaseWeb.CategoryController do
  use KaffebaseWeb, :controller

  alias Kaffebase.Catalog
  alias KaffebaseWeb.{ControllerHelpers, PBSerializer, ParamParser}

  action_fallback KaffebaseWeb.FallbackController

  def index(conn, params) do
    order = ParamParser.parse_sort(params["sort"])

    categories = Catalog.list_categories(order_by: default_order(order))
    meta = ParamParser.pagination(params, length(categories))

    response = Map.put(meta, :items, PBSerializer.resource(categories))
    json(conn, response)
  end

  def create(conn, params) do
    attrs = ControllerHelpers.atomize_keys(params)

    with {:ok, category} <- Catalog.create_category(attrs) do
      conn
      |> put_status(:created)
      |> json(PBSerializer.resource(category))
    end
  end

  def show(conn, %{"id" => id}) do
    category = Catalog.get_category!(id)
    json(conn, PBSerializer.resource(category))
  end

  def update(conn, %{"id" => id} = params) do
    category = Catalog.get_category!(id)
    attrs = ControllerHelpers.atomize_keys(Map.delete(params, "id"))

    with {:ok, category} <- Catalog.update_category(category, attrs) do
      json(conn, PBSerializer.resource(category))
    end
  end

  def delete(conn, %{"id" => id}) do
    category = Catalog.get_category!(id)

    with {:ok, _} <- Catalog.delete_category(category) do
      send_resp(conn, :no_content, "")
    end
  end

  defp default_order([]), do: [asc: :sort_order, asc: :name]
  defp default_order(order), do: order
end
