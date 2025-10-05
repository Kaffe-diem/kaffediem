defmodule KaffebaseWeb.CustomizationValueController do
  use KaffebaseWeb, :controller

  alias Kaffebase.Catalog
  alias KaffebaseWeb.{ControllerHelpers, PBSerializer, ParamParser}

  action_fallback KaffebaseWeb.FallbackController

  def index(conn, params) do
    order = ParamParser.parse_sort(params["sort"])
    belongs_to = params["belongs_to"] || params["key"] || params["key_id"]

    values =
      Catalog.list_customization_values(
        order_by: default_order(order),
        belongs_to: belongs_to
      )

    meta = ParamParser.pagination(params, length(values))
    response = Map.put(meta, :items, PBSerializer.resource(values))
    json(conn, response)
  end

  def create(conn, params) do
    attrs = ControllerHelpers.atomize_keys(params)

    with {:ok, value} <- Catalog.create_customization_value(attrs) do
      conn
      |> put_status(:created)
      |> json(PBSerializer.resource(value))
    end
  end

  def show(conn, %{"id" => id}) do
    value = Catalog.get_customization_value!(id)
    json(conn, PBSerializer.resource(value))
  end

  def update(conn, %{"id" => id} = params) do
    value = Catalog.get_customization_value!(id)
    attrs = ControllerHelpers.atomize_keys(Map.delete(params, "id"))

    with {:ok, value} <- Catalog.update_customization_value(value, attrs) do
      json(conn, PBSerializer.resource(value))
    end
  end

  def delete(conn, %{"id" => id}) do
    value = Catalog.get_customization_value!(id)

    with {:ok, _} <- Catalog.delete_customization_value(value) do
      send_resp(conn, :no_content, "")
    end
  end

  defp default_order([]), do: [asc: :sort_order, asc: :name]
  defp default_order(order), do: order
end
