defmodule KaffebaseWeb.MessageController do
  use KaffebaseWeb, :controller

  alias Kaffebase.Content
  alias KaffebaseWeb.{ControllerHelpers, PBSerializer, ParamParser}

  action_fallback KaffebaseWeb.FallbackController

  def index(conn, params) do
    messages = Content.list_messages()
    meta = ParamParser.pagination(params, length(messages))
    response = Map.put(meta, :items, PBSerializer.resource(messages))
    json(conn, response)
  end

  def create(conn, params) do
    attrs = ControllerHelpers.atomize_keys(params)

    with {:ok, message} <- Content.create_message(attrs) do
      conn
      |> put_status(:created)
      |> json(PBSerializer.resource(message))
    end
  end

  def show(conn, %{"id" => id}) do
    message = Content.get_message!(id)
    json(conn, PBSerializer.resource(message))
  end

  def update(conn, %{"id" => id} = params) do
    message = Content.get_message!(id)
    attrs = ControllerHelpers.atomize_keys(Map.delete(params, "id"))

    with {:ok, message} <- Content.update_message(message, attrs) do
      json(conn, PBSerializer.resource(message))
    end
  end

  def delete(conn, %{"id" => id}) do
    message = Content.get_message!(id)

    with {:ok, _} <- Content.delete_message(message) do
      send_resp(conn, :no_content, "")
    end
  end
end
