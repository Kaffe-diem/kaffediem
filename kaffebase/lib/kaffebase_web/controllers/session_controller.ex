defmodule KaffebaseWeb.SessionController do
  use KaffebaseWeb, :controller

  alias Kaffebase.Accounts

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
    case current_user(conn) do
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

  defp serialize_user(user) do
    %{
      id: user.id,
      name: user.name,
      is_admin: user.is_admin
    }
  end
end
