defmodule KaffebaseWeb.ItemCustomizationController do
  use KaffebaseWeb, :controller

  alias Kaffebase.Catalog.{Crud, ItemCustomization}

  action_fallback KaffebaseWeb.FallbackController

  def index(conn, _params) do
    customizations = Crud.list(ItemCustomization, [order_by: []], [])
    json(conn, customizations)
  end

  def show(conn, %{"id" => id}) do
    customization = Crud.get!(ItemCustomization, id)
    json(conn, customization)
  end

  def create(conn, params) do
    with {:ok, customization} <- Crud.create(ItemCustomization, params) do
      conn
      |> put_status(:created)
      |> json(customization)
    end
  end

  def update(conn, %{"id" => id} = params) do
    customization = Crud.get!(ItemCustomization, id)
    attrs = Map.delete(params, "id")

    with {:ok, customization} <- Crud.update(ItemCustomization, customization, attrs) do
      json(conn, customization)
    end
  end

  def delete(conn, %{"id" => id}) do
    customization = Crud.get!(ItemCustomization, id)

    with {:ok, _} <- Crud.delete(ItemCustomization, customization) do
      send_resp(conn, :no_content, "")
    end
  end
end
