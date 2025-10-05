defmodule KaffebaseWeb.CustomizationValueController do
  use KaffebaseWeb, :controller

  alias Kaffebase.Catalog
  alias KaffebaseWeb.{ControllerHelpers, DomainJSON}

  action_fallback KaffebaseWeb.FallbackController

  def index(conn, params) do
    belongs_to = params["belongs_to"] || params["key"] || params["key_id"]

    values =
      Catalog.list_customization_values(belongs_to: belongs_to)

    json(conn, DomainJSON.render(values))
  end

  def create(conn, params) do
    attrs = ControllerHelpers.atomize_keys(params)

    with {:ok, value} <- Catalog.create_customization_value(attrs) do
      conn
      |> put_status(:created)
      |> json(DomainJSON.render(value))
    end
  end

  def show(conn, %{"id" => id}) do
    value = Catalog.get_customization_value!(id)
    json(conn, DomainJSON.render(value))
  end

  def update(conn, %{"id" => id} = params) do
    value = Catalog.get_customization_value!(id)
    attrs = ControllerHelpers.atomize_keys(Map.delete(params, "id"))

    with {:ok, value} <- Catalog.update_customization_value(value, attrs) do
      json(conn, DomainJSON.render(value))
    end
  end

  def delete(conn, %{"id" => id}) do
    value = Catalog.get_customization_value!(id)

    with {:ok, _} <- Catalog.delete_customization_value(value) do
      send_resp(conn, :no_content, "")
    end
  end
end
