defmodule KaffebaseWeb.StatusController do
  use KaffebaseWeb, :controller

  alias Kaffebase.Content
  alias KaffebaseWeb.{ControllerHelpers, PBSerializer, ParamParser}

  action_fallback KaffebaseWeb.FallbackController

  @expand_mapping %{"message" => :message}

  def index(conn, params) do
    expand = ParamParser.parse_expand(params["expand"], @expand_mapping)

    statuses = Content.list_statuses(preload: expand)
    meta = ParamParser.pagination(params, length(statuses))
    response = Map.put(meta, :items, PBSerializer.resource(statuses))
    json(conn, response)
  end

  def first(conn, params) do
    expand = ParamParser.parse_expand(params["expand"], @expand_mapping)

    case Content.get_singleton_status(preload: expand) do
      nil -> send_resp(conn, :not_found, "")
      status -> json(conn, PBSerializer.resource(status))
    end
  end

  def create(conn, params) do
    attrs = ControllerHelpers.atomize_keys(params)

    with {:ok, status} <- Content.create_status(attrs) do
      conn
      |> put_status(:created)
      |> json(PBSerializer.resource(status))
    end
  end

  def show(conn, %{"id" => id} = params) do
    expand = ParamParser.parse_expand(params["expand"], @expand_mapping)

    status = Content.get_status!(id, preload: expand)
    json(conn, PBSerializer.resource(status))
  end

  def update(conn, %{"id" => id} = params) do
    status = Content.get_status!(id)
    attrs = ControllerHelpers.atomize_keys(Map.delete(params, "id"))

    with {:ok, status} <- Content.update_status(status, attrs) do
      json(conn, PBSerializer.resource(status))
    end
  end

  def delete(conn, %{"id" => id}) do
    status = Content.get_status!(id)

    with {:ok, _} <- Content.delete_status(status) do
      send_resp(conn, :no_content, "")
    end
  end
end
