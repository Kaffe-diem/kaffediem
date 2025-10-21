defmodule KaffebaseWeb.CustomizationKeyController do
  use KaffebaseWeb, :controller

  alias Kaffebase.Catalog.{Crud, CustomizationKey}

  action_fallback KaffebaseWeb.FallbackController

  def index(conn, _params) do
    keys = Crud.list(CustomizationKey)
    json(conn, keys)
  end

  def create(conn, params) do
    with {:ok, key} <- Crud.create(CustomizationKey, params) do
      conn
      |> put_status(:created)
      |> json(key)
    end
  end

  def show(conn, %{"id" => id}) do
    key = Crud.get!(CustomizationKey, id)
    json(conn, key)
  end

  def update(conn, %{"id" => id} = params) do
    key = Crud.get!(CustomizationKey, id)
    attrs = Map.delete(params, "id")

    with {:ok, key} <- Crud.update(CustomizationKey, key, attrs) do
      json(conn, key)
    end
  end

  def delete(conn, %{"id" => id}) do
    key = Crud.get!(CustomizationKey, id)

    with {:ok, _} <- Crud.delete(CustomizationKey, key) do
      send_resp(conn, :no_content, "")
    end
  end
end
