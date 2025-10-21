defmodule KaffebaseWeb.ItemController do
  use KaffebaseWeb, :controller

  alias Kaffebase.Catalog.{Crud, Item}

  action_fallback KaffebaseWeb.FallbackController

  def index(conn, params) do
    category_id = params["category"] || params["category_id"]

    opts =
      []
      |> maybe_put_filter(category_id)

    items = Crud.list(Item, opts)
    json(conn, items)
  end

  def create(conn, params) do
    with {:ok, item} <- Crud.create(Item, params) do
      conn
      |> put_status(:created)
      |> json(item)
    end
  end

  def show(conn, %{"id" => id}) do
    item = Crud.get!(Item, id)
    json(conn, item)
  end

  def update(conn, %{"id" => id} = params) do
    item = Crud.get!(Item, id)
    attrs = Map.delete(params, "id")

    with {:ok, item} <- Crud.update(Item, item, attrs) do
      json(conn, item)
    end
  end

  def delete(conn, %{"id" => id}) do
    item = Crud.get!(Item, id)

    with {:ok, _} <- Crud.delete(Item, item) do
      send_resp(conn, :no_content, "")
    end
  end

  defp maybe_put_filter(opts, nil), do: opts
  defp maybe_put_filter(opts, category_id), do: Keyword.put(opts, :filter, {:category, category_id})
end
