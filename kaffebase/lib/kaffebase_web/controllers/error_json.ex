defmodule KaffebaseWeb.ErrorJSON do
  require Logger

  # Log and render 500 errors with context
  def render("500.json", %{conn: conn, kind: kind, reason: reason, stack: _stack} = assigns) do
    log_error(conn, kind, reason)
    render("500.json", assigns)
  end

  def render("500.json", _assigns) do
    %{errors: %{detail: "Internal Server Error"}}
  end

  # Log 404 errors from raised Ecto.NoResultsError
  def render("404.json", %{conn: conn, kind: :error, reason: %Ecto.NoResultsError{}} = assigns) do
    Logger.warning("Resource not found (404): #{conn.request_path} - Ecto.NoResultsError")
    render("404.json", assigns)
  end

  def render("404.json", _assigns) do
    %{errors: %{detail: "Not Found"}}
  end

  # By default, Phoenix returns the status message from
  # the template name. For example, "404.json" becomes
  # "Not Found".
  def render(template, _assigns) do
    %{errors: %{detail: Phoenix.Controller.status_message_from_template(template)}}
  end

  defp log_error(conn, kind, reason) do
    Logger.error("""
    Internal server error (500): #{conn.request_path}
    Kind: #{inspect(kind)}
    Reason: #{Exception.message(reason)}
    """)
  end
end
