defmodule KaffebaseWeb.FallbackController do
  use KaffebaseWeb, :controller
  require Logger

  alias Ecto.Changeset

  def call(conn, {:error, %Changeset{} = changeset}) do
    Logger.warning("Validation failed (422): #{inspect(changeset.errors)}")

    conn
    |> put_status(:unprocessable_entity)
    |> json(KaffebaseWeb.ChangesetJSON.error(%{changeset: changeset}))
  end

  def call(conn, {:error, :not_found}) do
    Logger.info("Resource not found (404): #{conn.request_path}")

    send_resp(conn, :not_found, "")
  end

  def call(conn, {:error, :unauthorized}) do
    Logger.info("Unauthorized request (401): #{conn.request_path}")

    send_resp(conn, :unauthorized, "")
  end
end
