defmodule Kaffebase.Catalog.Category do
  use Ecto.Schema

  @primary_key {:id, :string, autogenerate: false}

  schema "category" do
    field :created_at, :string, source: :created
    field :enable, :boolean
    field :name, :string
    field :sort_order, :integer
    field :updated_at, :string, source: :updated
    field :valid_customizations, :map, source: :valid_customizations
  end
end
