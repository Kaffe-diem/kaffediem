defmodule KaffebaseWeb.CustomizationValueController do
  use KaffebaseWeb, :controller

  alias Kaffebase.Catalog.{Crud, CustomizationValue}

  action_fallback KaffebaseWeb.FallbackController

  def index(conn, params) do
    belongs_to = params["belongs_to"] || params["key"] || params["key_id"]

    values = Crud.list(CustomizationValue, build_filter_opts(belongs_to))

    json(conn, values)
  end

  def create(conn, params) do
    with {:ok, value} <- Crud.create(CustomizationValue, params) do
      conn
      |> put_status(:created)
      |> json(value)
    end
  end

  def show(conn, %{"id" => id}) do
    value = Crud.get!(CustomizationValue, id)
    json(conn, value)
  end

  def update(conn, %{"id" => id} = params) do
    value = Crud.get!(CustomizationValue, id)
    attrs = Map.delete(params, "id")

    with {:ok, value} <- Crud.update(CustomizationValue, value, attrs) do
      json(conn, value)
    end
  end

  def delete(conn, %{"id" => id}) do
    value = Crud.get!(CustomizationValue, id)

    with {:ok, _} <- Crud.delete(CustomizationValue, value) do
      send_resp(conn, :no_content, "")
    end
  end

  defp build_filter_opts(nil), do: []
  defp build_filter_opts(key_id), do: [filter: {:belongs_to, key_id}]
end
