defmodule KaffebaseWeb.ItemCustomizationController do
  use KaffebaseWeb, :controller

  alias Kaffebase.Catalog
  alias KaffebaseWeb.{ControllerHelpers, DomainJSON}

  action_fallback KaffebaseWeb.FallbackController

  def index(conn, _params) do
    customizations = Catalog.list_item_customizations(preload: [:key, :values])
    json(conn, DomainJSON.render(customizations))
  end

  def show(conn, %{"id" => id}) do
    customization = Catalog.get_item_customization!(id, preload: [:key, :values])
    json(conn, DomainJSON.render(customization))
  end

  def create(conn, params) do
    attrs = ControllerHelpers.atomize_keys(params)

    with {:ok, customization} <- Catalog.create_item_customization(attrs) do
      conn
      |> put_status(:created)
      |> json(DomainJSON.render(customization))
    end
  end

  def update(conn, %{"id" => id} = params) do
    customization = Catalog.get_item_customization!(id)
    attrs = ControllerHelpers.atomize_keys(Map.delete(params, "id"))

    with {:ok, customization} <- Catalog.update_item_customization(customization, attrs) do
      json(conn, DomainJSON.render(customization))
    end
  end

  def delete(conn, %{"id" => id}) do
    customization = Catalog.get_item_customization!(id)

    with {:ok, _} <- Catalog.delete_item_customization(customization) do
      send_resp(conn, :no_content, "")
    end
  end
end
