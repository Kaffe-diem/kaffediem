defmodule Kaffebase.Catalog.CustomizationKey do
  use Ecto.Schema
  import Ecto.Changeset

  schema "customization_key" do
    field :default_value, :string
    field :enable, :boolean
    field :label_color, :string, source: :label_color
    field :multiple_choice, :boolean, source: :multiple_choice
    field :name, :string
    field :sort_order, :integer

    timestamps()
  end

  @doc false
  def changeset(customization_key, attrs) do
    customization_key
    |> cast(attrs, [
      :default_value,
      :enable,
      :label_color,
      :multiple_choice,
      :name,
      :sort_order
    ])
    |> validate_required([:name])
  end
end

defimpl Jason.Encoder, for: Kaffebase.Catalog.CustomizationKey do
  def encode(key, opts) do
    Jason.Encode.map(
      %{
        id: key.id,
        name: key.name,
        enable: key.enable,
        label_color: key.label_color,
        default_value: key.default_value,
        multiple_choice: key.multiple_choice,
        sort_order: key.sort_order,
        inserted_at: key.inserted_at,
        updated_at: key.updated_at
      },
      opts
    )
  end
end
