defmodule Kaffebase.Content.Message do
  use Ecto.Schema

  @primary_key {:id, :string, autogenerate: false}

  schema "message" do
    field :created_at, :string, source: :created
    field :subtitle, :string
    field :title, :string
    field :updated_at, :string, source: :updated
  end
end
