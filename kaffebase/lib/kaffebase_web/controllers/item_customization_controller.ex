defmodule KaffebaseWeb.ItemCustomizationController do
  use KaffebaseWeb, :controller

  alias Kaffebase.Catalog
  alias KaffebaseWeb.{ControllerHelpers, PBSerializer, ParamParser}

  action_fallback KaffebaseWeb.FallbackController

  @expand_mapping %{
    "key" => :key,
    "key_expand" => :key,
    "value" => :values,
    "values" => :values
  }

  def index(conn, params) do
    expand = ParamParser.parse_expand(params["expand"], @expand_mapping)

    customizations = Catalog.list_item_customizations(preload: expand)
    meta = ParamParser.pagination(params, length(customizations))
    response = Map.put(meta, :items, PBSerializer.resource(customizations))
    json(conn, response)
  end

  def show(conn, %{"id" => id} = params) do
    expand = ParamParser.parse_expand(params["expand"], @expand_mapping)

    customization = Catalog.get_item_customization!(id, preload: expand)
    json(conn, PBSerializer.resource(customization))
  end

  def create(conn, params) do
    attrs = ControllerHelpers.atomize_keys(params)

    with {:ok, customization} <- Catalog.create_item_customization(attrs) do
      conn
      |> put_status(:created)
      |> json(PBSerializer.resource(customization))
    end
  end

  def update(conn, %{"id" => id} = params) do
    customization = Catalog.get_item_customization!(id)
    attrs = ControllerHelpers.atomize_keys(Map.delete(params, "id"))

    with {:ok, customization} <- Catalog.update_item_customization(customization, attrs) do
      json(conn, PBSerializer.resource(customization))
    end
  end

  def delete(conn, %{"id" => id}) do
    customization = Catalog.get_item_customization!(id)

    with {:ok, _} <- Catalog.delete_item_customization(customization) do
      send_resp(conn, :no_content, "")
    end
  end
end
