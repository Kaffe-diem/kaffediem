defmodule Kaffebase.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias Kaffebase.Ids

  @primary_key {:id, :string, autogenerate: false}
  @timestamps_opts [type: :utc_datetime_usec, inserted_at: :created, updated_at: :updated]

  schema "user" do
    field :avatar, :string
    field :email, :string
    field :email_visibility, :boolean, source: :emailVisibility
    field :is_admin, :boolean, source: :is_admin
    field :name, :string
    field :password, :string
    field :token_key, :string, source: :tokenKey
    field :username, :string
    field :verified, :boolean

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [
      :id,
      :avatar,
      :email,
      :email_visibility,
      :is_admin,
      :name,
      :password,
      :token_key,
      :username,
      :verified
    ])
    |> maybe_put_id()
    |> validate_required([:name, :username, :password])
    |> maybe_hash_password()
  end

  defp maybe_put_id(changeset) do
    case fetch_field(changeset, :id) do
      {:data, nil} -> put_change(changeset, :id, Ids.generate())
      {:changes, nil} -> put_change(changeset, :id, Ids.generate())
      _ -> changeset
    end
  end

  defp maybe_hash_password(changeset) do
    if password = get_change(changeset, :password) do
      hashed = Bcrypt.hash_pwd_salt(password)
      put_change(changeset, :password, hashed)
    else
      changeset
    end
  end
end
