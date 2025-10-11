defmodule KaffebaseWeb.SessionControllerTest do
  use KaffebaseWeb.ConnCase

  alias Kaffebase.Accounts

  import Kaffebase.AccountsFixtures

  describe "GET /api/session" do
    setup %{conn: conn} do
      default = Application.get_env(:kaffebase, :dev_auto_login, false)
      on_exit(fn -> Application.put_env(:kaffebase, :dev_auto_login, default) end)

      {:ok, conn: conn}
    end

    test "returns 204 when auto login is disabled", %{conn: conn} do
      Application.put_env(:kaffebase, :dev_auto_login, false)

      conn = get(conn, ~p"/api/session")
      assert response(conn, 204)
    end

    test "auto logs an admin user when enabled", %{conn: conn} do
      Application.put_env(:kaffebase, :dev_auto_login, true)

      conn = get(conn, ~p"/api/session")
      assert %{"data" => data} = json_response(conn, 200)
      assert data["is_admin"]
      assert get_session(conn, :user_id) == data["id"]

      # ensure the user really exists in storage for downstream calls
      assert %{} = Accounts.get_user(data["id"])
    end
  end

  describe "POST /api/session" do
    setup do
      user =
        user_fixture()
        |> set_password()

      %{user: user}
    end

    test "logs in a user with valid credentials", %{conn: conn, user: user} do
      conn = post(conn, ~p"/api/session", %{email: user.email, password: valid_user_password()})

      assert %{"data" => data} = json_response(conn, 200)
      assert data["id"] == user.id
      assert get_session(conn, :user_id) == user.id
    end

    test "returns unauthorized when password is invalid", %{conn: conn, user: user} do
      conn = post(conn, ~p"/api/session", %{email: user.email, password: "wrong-password"})

      assert response(conn, 401)
    end

    test "returns not found when user is missing", %{conn: conn} do
      conn = post(conn, ~p"/api/session", %{email: "missing@example.com", password: "whatever"})

      assert response(conn, 404)
    end
  end
end
