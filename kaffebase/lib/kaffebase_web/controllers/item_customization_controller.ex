defmodule KaffebaseWeb.ItemCustomizationController do
  use KaffebaseWeb, :controller

  alias Kaffebase.Catalog

  action_fallback KaffebaseWeb.FallbackController

  def index(conn, _params) do
    customizations = Catalog.list_item_customizations()
    json(conn, customizations)
  end

  def show(conn, %{"id" => id}) do
    customization = Catalog.get_item_customization!(id)
    json(conn, customization)
  end

  def create(conn, params) do

    with {:ok, customization} <- Catalog.create_item_customization(params) do
      conn
      |> put_status(:created)
      |> json(customization)
    end
  end

  def update(conn, %{"id" => id} = params) do
    customization = Catalog.get_item_customization!(id)
    attrs = Map.delete(params, "id")

    with {:ok, customization} <- Catalog.update_item_customization(customization, attrs) do
      json(conn, customization)
    end
  end

  def delete(conn, %{"id" => id}) do
    customization = Catalog.get_item_customization!(id)

    with {:ok, _} <- Catalog.delete_item_customization(customization) do
      send_resp(conn, :no_content, "")
    end
  end
end
