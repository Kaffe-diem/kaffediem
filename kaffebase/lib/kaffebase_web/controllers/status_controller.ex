defmodule KaffebaseWeb.StatusController do
  use KaffebaseWeb, :controller

  alias Kaffebase.Content
  alias KaffebaseWeb.{ControllerHelpers, DomainJSON}

  action_fallback KaffebaseWeb.FallbackController

  def index(conn, _params) do
    statuses = Content.list_statuses(preload: [:message])
    json(conn, DomainJSON.render(statuses))
  end

  def first(conn, _params) do
    case Content.get_singleton_status(preload: [:message]) do
      nil -> send_resp(conn, :not_found, "")
      status -> json(conn, DomainJSON.render(status))
    end
  end

  def create(conn, params) do
    attrs = ControllerHelpers.atomize_keys(params)

    with {:ok, status} <- Content.create_status(attrs) do
      conn
      |> put_status(:created)
      |> json(DomainJSON.render(status))
    end
  end

  def show(conn, %{"id" => id}) do
    status = Content.get_status!(id, preload: [:message])
    json(conn, DomainJSON.render(status))
  end

  def update(conn, %{"id" => id} = params) do
    status = Content.get_status!(id)
    attrs = ControllerHelpers.atomize_keys(Map.delete(params, "id"))

    with {:ok, status} <- Content.update_status(status, attrs) do
      json(conn, DomainJSON.render(status))
    end
  end

  def delete(conn, %{"id" => id}) do
    status = Content.get_status!(id)

    with {:ok, _} <- Content.delete_status(status) do
      send_resp(conn, :no_content, "")
    end
  end
end
