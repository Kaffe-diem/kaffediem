defmodule KaffebaseWeb.MessageController do
  use KaffebaseWeb, :controller

  alias Kaffebase.Content

  action_fallback KaffebaseWeb.FallbackController

  def index(conn, _params) do
    messages = Content.list_messages()
    json(conn, messages)
  end

  def create(conn, params) do

    with {:ok, message} <- Content.create_message(params) do
      conn
      |> put_status(:created)
      |> json(message)
    end
  end

  def show(conn, %{"id" => id}) do
    message = Content.get_message!(id)
    json(conn, message)
  end

  def update(conn, %{"id" => id} = params) do
    message = Content.get_message!(id)
    attrs = Map.delete(params, "id")

    with {:ok, message} <- Content.update_message(message, attrs) do
      json(conn, message)
    end
  end

  def delete(conn, %{"id" => id}) do
    message = Content.get_message!(id)

    with {:ok, _} <- Content.delete_message(message) do
      send_resp(conn, :no_content, "")
    end
  end
end
