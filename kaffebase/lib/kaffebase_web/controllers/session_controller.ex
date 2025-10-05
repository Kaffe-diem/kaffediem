defmodule KaffebaseWeb.SessionController do
  use KaffebaseWeb, :controller

  alias Kaffebase.Accounts

  require Logger

  action_fallback KaffebaseWeb.FallbackController

  def create(conn, %{"email" => email, "password" => password}) do
    with {:ok, user} <- verify_credentials(email, password) do
      conn
      |> put_session(:user_id, user.id)
      |> json(%{
        "record" => serialize_user(user)
      })
    end
  end

  def delete(conn, _params) do
    conn
    |> configure_session(drop: true)
    |> send_resp(:no_content, "")
  end

  def show(conn, _params) do
    {conn, user} = ensure_session(conn)

    case user do
      nil ->
        send_resp(conn, :no_content, "")

      user ->
        json(conn, %{
          "record" => serialize_user(user)
        })
    end
  end

  defp verify_credentials(email, password) do
    case Accounts.get_user_by_email(email) do
      nil ->
        {:error, :not_found}

      user ->
        case Bcrypt.verify_pass(password, user.password) do
          true -> {:ok, user}
          false -> {:error, :unauthorized}
        end
    end
  end

  defp current_user(conn) do
    with user_id when is_binary(user_id) <- get_session(conn, :user_id) do
      Accounts.get_user(user_id)
    end
  end

  defp ensure_session(conn) do
    case current_user(conn) do
      %{} = user ->
        {conn, user}

      nil ->
        maybe_bootstrap_dev_session(conn)
    end
  end

  defp maybe_bootstrap_dev_session(conn) do
    if dev_auto_login?() do
      case Accounts.ensure_admin_user() do
        {:ok, user} ->
          {put_session(conn, :user_id, user.id), user}

        {:error, changeset} ->
          Logger.warning("Failed to provision development admin: #{inspect(changeset.errors)}")
          {conn, nil}
      end
    else
      {conn, nil}
    end
  end

  defp dev_auto_login? do
    Application.get_env(:kaffebase, :dev_auto_login, false)
  end

  defp serialize_user(user) do
    %{
      id: user.id,
      name: user.name,
      is_admin: user.is_admin
    }
  end
end
