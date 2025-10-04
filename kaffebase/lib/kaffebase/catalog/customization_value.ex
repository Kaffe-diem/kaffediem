defmodule Kaffebase.Catalog.CustomizationValue do
  use Ecto.Schema

  @primary_key {:id, :string, autogenerate: false}

  schema "customization_value" do
    field :belongs_to_key_id, :string, source: :belongs_to
    field :constant_price, :boolean, source: :constant_price
    field :created_at, :string, source: :created
    field :enable, :boolean
    field :name, :string
    field :price_increment_nok, :decimal, source: :price_increment_nok
    field :sort_order, :integer
    field :updated_at, :string, source: :updated
  end
end
