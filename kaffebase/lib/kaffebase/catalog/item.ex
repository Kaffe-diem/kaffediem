defmodule Kaffebase.Catalog.Item do
  use Ecto.Schema
  import Ecto.Changeset

  alias Kaffebase.Catalog.Category

  schema "item" do
    belongs_to :category, Category
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
    |> cast(attrs, [:category_id, :enable, :image, :name, :price_nok, :sort_order])
    |> validate_required([:name, :price_nok, :category_id])
    |> foreign_key_constraint(:category_id)
  end
end

defimpl Jason.Encoder, for: Kaffebase.Catalog.Item do
  def encode(item, opts) do
    category_name =
      case item.category do
        %Kaffebase.Catalog.Category{name: name} -> name
        _ -> nil
      end

    Jason.Encode.map(
      %{
        id: item.id,
        name: item.name,
        price_nok: decimal_to_float(item.price_nok),
        category_id: item.category_id,
        category_name: category_name,
        image: item.image,
        enable: item.enable,
        sort_order: item.sort_order,
        inserted_at: item.inserted_at,
        updated_at: item.updated_at
      },
      opts
    )
  end

  defp decimal_to_float(nil), do: nil
  defp decimal_to_float(%Decimal{} = decimal), do: Decimal.to_float(decimal)
  defp decimal_to_float(number) when is_number(number), do: number
end
