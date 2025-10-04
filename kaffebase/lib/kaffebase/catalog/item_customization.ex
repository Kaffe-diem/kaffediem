defmodule Kaffebase.Catalog.ItemCustomization do
  use Ecto.Schema

  @primary_key {:id, :string, autogenerate: false}

  schema "item_customization" do
    field :created_at, :string, source: :created
    field :key_id, :string, source: :key
    field :updated_at, :string, source: :updated
    field :value, :map
  end
end
