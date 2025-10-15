defmodule KaffebaseWeb.CustomizationValueController do
  use KaffebaseWeb, :controller

  alias Kaffebase.Catalog

  action_fallback KaffebaseWeb.FallbackController

  def index(conn, params) do
    belongs_to = params["belongs_to"] || params["key"] || params["key_id"]

    values =
      Catalog.list_customization_values(belongs_to: belongs_to)

    json(conn, values)
  end

  def create(conn, params) do

    with {:ok, value} <- Catalog.create_customization_value(params) do
      conn
      |> put_status(:created)
      |> json(value)
    end
  end

  def show(conn, %{"id" => id}) do
    value = Catalog.get_customization_value!(id)
    json(conn, value)
  end

  def update(conn, %{"id" => id} = params) do
    value = Catalog.get_customization_value!(id)
    attrs = Map.delete(params, "id")

    with {:ok, value} <- Catalog.update_customization_value(value, attrs) do
      json(conn, value)
    end
  end

  def delete(conn, %{"id" => id}) do
    value = Catalog.get_customization_value!(id)

    with {:ok, _} <- Catalog.delete_customization_value(value) do
      send_resp(conn, :no_content, "")
    end
  end
end
