defmodule Kaffebase.Catalog.CustomizationKey do
  use Ecto.Schema

  @primary_key {:id, :string, autogenerate: false}

  schema "customization_key" do
    field :created_at, :string, source: :created
    field :default_value, :string, source: :default_value
    field :enable, :boolean
    field :label_color, :string, source: :label_color
    field :multiple_choice, :boolean, source: :multiple_choice
    field :name, :string
    field :sort_order, :integer
    field :updated_at, :string, source: :updated
  end
end
