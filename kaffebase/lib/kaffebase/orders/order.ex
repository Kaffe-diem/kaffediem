defmodule Kaffebase.Orders.Order do
  use Ecto.Schema

  @primary_key {:id, :string, autogenerate: false}

  schema "order" do
    field :created_at, :string, source: :created
    field :customer, :string
    field :day_id, :integer, source: :day_id
    field :items, :map
    field :missing_information, :boolean, source: :missing_information
    field :state, :string
    field :updated_at, :string, source: :updated
  end
end
