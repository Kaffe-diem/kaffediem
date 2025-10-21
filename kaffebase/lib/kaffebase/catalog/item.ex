defmodule Kaffebase.Catalog.Item do
  use Ecto.Schema
  import Ecto.Changeset

  alias Kaffebase.Ids

  @primary_key {:id, :string, autogenerate: false}

  schema "item" do
    field :category, :string
    field :enable, :boolean
    field :image, :string
    field :name, :string
    field :price_nok, :decimal, source: :price_nok
    field :sort_order, :integer

    timestamps()
  end

  @doc false
  def changeset(item, attrs) do
    item
    |> cast(attrs, [:id, :category, :enable, :image, :name, :price_nok, :sort_order])
    |> maybe_put_id()
    |> validate_required([:name, :price_nok, :category])
  end

  defp maybe_put_id(changeset) do
    case fetch_field(changeset, :id) do
      {:data, nil} -> put_change(changeset, :id, Ids.generate())
      {:changes, nil} -> put_change(changeset, :id, Ids.generate())
      _ -> changeset
    end
  end
end

defimpl Jason.Encoder, for: Kaffebase.Catalog.Item do
  def encode(item, opts) do
    Jason.Encode.map(
      %{
        id: item.id,
        name: item.name,
        price_nok: if(item.price_nok, do: Decimal.to_float(item.price_nok), else: nil),
        category: item.category,
        image: item.image,
        enable: item.enable,
        sort_order: item.sort_order,
        inserted_at: item.inserted_at,
        updated_at: item.updated_at
      },
      opts
    )
  end
end
