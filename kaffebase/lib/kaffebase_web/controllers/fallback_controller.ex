defmodule KaffebaseWeb.FallbackController do
  use KaffebaseWeb, :controller

  alias Ecto.Changeset

  def call(conn, {:error, %Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> json(KaffebaseWeb.ChangesetJSON.error(%{changeset: changeset}))
  end

  def call(conn, {:error, :not_found}) do
    send_resp(conn, :not_found, "")
  end
end
