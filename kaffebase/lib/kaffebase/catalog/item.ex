defmodule Kaffebase.Catalog.Item do
  use Ecto.Schema

  @primary_key {:id, :string, autogenerate: false}
  @foreign_key_type :string

  schema "item" do
    field :category, :string
    field :created_at, :string, source: :created
    field :enable, :boolean
    field :image, :string
    field :name, :string
    field :price_nok, :decimal, source: :price_nok
    field :sort_order, :integer
    field :updated_at, :string, source: :updated
  end
end
