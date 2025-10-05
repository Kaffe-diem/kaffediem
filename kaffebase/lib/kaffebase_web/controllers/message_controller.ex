defmodule KaffebaseWeb.MessageController do
  use KaffebaseWeb, :controller

  alias Kaffebase.Content
  alias KaffebaseWeb.{ControllerHelpers, DomainJSON}

  action_fallback KaffebaseWeb.FallbackController

  def index(conn, _params) do
    messages = Content.list_messages()
    json(conn, DomainJSON.render(messages))
  end

  def create(conn, params) do
    attrs = ControllerHelpers.atomize_keys(params)

    with {:ok, message} <- Content.create_message(attrs) do
      conn
      |> put_status(:created)
      |> json(DomainJSON.render(message))
    end
  end

  def show(conn, %{"id" => id}) do
    message = Content.get_message!(id)
    json(conn, DomainJSON.render(message))
  end

  def update(conn, %{"id" => id} = params) do
    message = Content.get_message!(id)
    attrs = ControllerHelpers.atomize_keys(Map.delete(params, "id"))

    with {:ok, message} <- Content.update_message(message, attrs) do
      json(conn, DomainJSON.render(message))
    end
  end

  def delete(conn, %{"id" => id}) do
    message = Content.get_message!(id)

    with {:ok, _} <- Content.delete_message(message) do
      send_resp(conn, :no_content, "")
    end
  end
end
