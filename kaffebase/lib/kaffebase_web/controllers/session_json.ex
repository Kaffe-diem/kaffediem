defmodule KaffebaseWeb.SessionJSON do
  alias Kaffebase.Accounts.User

  @doc "Renders the current authenticated user payload"
  def show(%{user: %User{} = user}) do
    %{data: user(user)}
  end

  def show(%{user: nil}) do
    %{data: nil}
  end

  defp user(%User{} = user) do
    %{
      id: user.id,
      name: user.name,
      is_admin: user.is_admin
    }
  end
end
