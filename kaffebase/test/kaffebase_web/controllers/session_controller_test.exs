defmodule KaffebaseWeb.SessionControllerTest do
  use KaffebaseWeb.ConnCase

  alias Kaffebase.Accounts

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
      assert %{"record" => record} = json_response(conn, 200)
      assert record["is_admin"]
      assert get_session(conn, :user_id) == record["id"]

      # ensure the user really exists in storage for downstream calls
      assert %{} = Accounts.get_user(record["id"])
    end
  end
end
