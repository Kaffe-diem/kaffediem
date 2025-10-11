defmodule KaffebaseWeb.CustomizationKeyController do
  use KaffebaseWeb, :controller

  alias Kaffebase.Catalog
  alias KaffebaseWeb.{ControllerHelpers, DomainJSON}

  action_fallback KaffebaseWeb.FallbackController

  def index(conn, _params) do
    keys = Catalog.list_customization_keys()
    json(conn, DomainJSON.render(keys))
  end

  def create(conn, params) do
    attrs = ControllerHelpers.atomize_keys(params)

    with {:ok, key} <- Catalog.create_customization_key(attrs) do
      conn
      |> put_status(:created)
      |> json(DomainJSON.render(key))
    end
  end

  def show(conn, %{"id" => id}) do
    key = Catalog.get_customization_key!(id)
    json(conn, DomainJSON.render(key))
  end

  def update(conn, %{"id" => id} = params) do
    key = Catalog.get_customization_key!(id)
    attrs = ControllerHelpers.atomize_keys(Map.delete(params, "id"))

    with {:ok, key} <- Catalog.update_customization_key(key, attrs) do
      json(conn, DomainJSON.render(key))
    end
  end

  def delete(conn, %{"id" => id}) do
    key = Catalog.get_customization_key!(id)

    with {:ok, _} <- Catalog.delete_customization_key(key) do
      send_resp(conn, :no_content, "")
    end
  end
end
