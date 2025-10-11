defmodule KaffebaseWeb.PageController do
  use KaffebaseWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
