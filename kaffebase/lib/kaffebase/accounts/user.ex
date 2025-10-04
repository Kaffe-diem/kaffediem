defmodule Kaffebase.Accounts.User do
  use Ecto.Schema

  @primary_key {:id, :string, autogenerate: false}

  schema "user" do
    field :avatar, :string
    field :created_at, :string, source: :created
    field :email, :string
    field :email_visibility, :boolean, source: :emailVisibility
    field :name, :string
    field :password, :string
    field :token_key, :string, source: :tokenKey
    field :updated_at, :string, source: :updated
    field :username, :string
    field :verified, :boolean
    field :is_admin, :boolean, source: :is_admin
  end
end
