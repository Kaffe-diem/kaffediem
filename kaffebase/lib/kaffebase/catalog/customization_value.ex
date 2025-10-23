defmodule Kaffebase.Catalog.CustomizationValue do
  use Ecto.Schema
  import Ecto.Changeset

  alias Kaffebase.Ids

  @primary_key {:id, :string, autogenerate: false}

  schema "customization_value" do
    field :constant_price, :boolean, source: :constant_price
    field :enable, :boolean
    field :belongs_to, :string
    field :name, :string
    field :price_increment_nok, :decimal, source: :price_increment_nok
    field :sort_order, :integer

    timestamps()
  end

  @doc false
  def changeset(customization_value, attrs) do
    customization_value
    |> cast(attrs, [
      :id,
      :constant_price,
      :enable,
      :belongs_to,
      :name,
      :price_increment_nok,
      :sort_order
    ])
    |> maybe_put_id()
    |> validate_required([:name, :belongs_to])
  end

  defp maybe_put_id(changeset) do
    case fetch_field(changeset, :id) do
      {:data, nil} -> put_change(changeset, :id, Ids.generate())
      {:changes, nil} -> put_change(changeset, :id, Ids.generate())
      _ -> changeset
    end
  end
end

defimpl Jason.Encoder, for: Kaffebase.Catalog.CustomizationValue do
  def encode(value, opts) do
    Jason.Encode.map(
      %{
        id: value.id,
        name: value.name,
        price_increment_nok: if(value.price_increment_nok, do: Decimal.to_float(value.price_increment_nok), else: nil),
        constant_price: value.constant_price,
        belongs_to: value.belongs_to,
        enable: value.enable,
        sort_order: value.sort_order,
        inserted_at: value.inserted_at,
        updated_at: value.updated_at
      },
      opts
    )
  end
end
