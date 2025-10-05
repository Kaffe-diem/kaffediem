defmodule Kaffebase.AccountsFixtures do
  @moduledoc false

  alias Kaffebase.Accounts

  def unique_string(prefix) do
    unique = System.unique_integer([:positive, :monotonic])
    "#{prefix}_#{unique}"
  end

  def user_fixture(attrs \\ %{}) do
    defaults = %{
      username: unique_string("user"),
      name: unique_string("User"),
      email: unique_string("user") <> "@example.com",
      password: unique_string("pass"),
      token_key: unique_string("token"),
      verified: false,
      is_admin: false,
      email_visibility: false
    }

    {:ok, user} =
      attrs
      |> Enum.into(defaults)
      |> Accounts.create_user()

    user
  end
end
