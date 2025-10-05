defmodule Kaffebase.Accounts do
  @moduledoc """
  Accounts context covering user data previously sourced from PocketBase.
  """

  import Ecto.Query, warn: false

  alias Kaffebase.Accounts.User
  alias Kaffebase.Repo
  alias Ecto.UUID

  @spec list_users(keyword()) :: [User.t()]
  def list_users(_opts \\ []), do: Repo.all(User)

  @spec get_user!(String.t()) :: User.t()
  def get_user!(id), do: Repo.get!(User, id)

  @spec get_user(String.t()) :: User.t() | nil
  def get_user(id), do: Repo.get(User, id)

  @spec get_user_by_email(String.t()) :: User.t() | nil
  def get_user_by_email(email) when is_binary(email) do
    Repo.get_by(User, email: email)
  end

  @spec get_user_by_username(String.t()) :: User.t() | nil
  def get_user_by_username(username) when is_binary(username) do
    Repo.get_by(User, username: username)
  end

  @spec create_user(map()) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @spec update_user(User.t(), map()) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @spec delete_user(User.t()) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def delete_user(%User{} = user), do: Repo.delete(user)

  @spec change_user(User.t(), map()) :: Ecto.Changeset.t()
  def change_user(%User{} = user, attrs \\ %{}), do: User.changeset(user, attrs)

  @spec ensure_admin_user() :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def ensure_admin_user do
    query = from u in User, where: u.is_admin, order_by: [asc: u.created], limit: 1

    case Repo.one(query) do
      %User{} = user ->
        {:ok, user}

      nil ->
        create_user(default_dev_admin_attrs())
    end
  end

  defp default_dev_admin_attrs do
    %{
      name: "Dev Admin",
      username: "dev-admin",
      email: "dev-admin@kaffediem.local",
      password: "dev-admin",
      is_admin: true,
      email_visibility: false,
      verified: true,
      token_key: UUID.generate()
    }
  end
end
