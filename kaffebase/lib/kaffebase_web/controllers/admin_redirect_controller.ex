defmodule KaffebaseWeb.AdminRedirectController do
  use KaffebaseWeb, :controller

  def redirect_to_items(conn, _params) do
    conn
    |> redirect(to: ~p"/admin/items")
    |> Plug.Conn.halt()
  end
end
