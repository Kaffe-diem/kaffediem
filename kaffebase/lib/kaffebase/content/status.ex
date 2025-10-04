defmodule Kaffebase.Content.Status do
  use Ecto.Schema

  @primary_key {:id, :string, autogenerate: false}

  schema "status" do
    field :created_at, :string, source: :created
    field :message, :string
    field :open, :boolean
    field :show_message, :boolean, source: :show_message
    field :updated_at, :string, source: :updated
  end
end
