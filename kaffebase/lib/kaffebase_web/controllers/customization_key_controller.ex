defmodule KaffebaseWeb.CustomizationKeyController do
  use KaffebaseWeb, :controller

  alias Kaffebase.Catalog

  action_fallback KaffebaseWeb.FallbackController

  def index(conn, _params) do
    keys = Catalog.list_customization_keys()
    json(conn, keys)
  end

  def create(conn, params) do

    with {:ok, key} <- Catalog.create_customization_key(params) do
      conn
      |> put_status(:created)
      |> json(key)
    end
  end

  def show(conn, %{"id" => id}) do
    key = Catalog.get_customization_key!(id)
    json(conn, key)
  end

  def update(conn, %{"id" => id} = params) do
    key = Catalog.get_customization_key!(id)
    attrs = Map.delete(params, "id")

    with {:ok, key} <- Catalog.update_customization_key(key, attrs) do
      json(conn, key)
    end
  end

  def delete(conn, %{"id" => id}) do
    key = Catalog.get_customization_key!(id)

    with {:ok, _} <- Catalog.delete_customization_key(key) do
      send_resp(conn, :no_content, "")
    end
  end
end
