defmodule Kaffebase.Catalog.Category do
  use Ecto.Schema
  import Ecto.Changeset

  # Stores a single customization key ID inside the category snapshot.
  defmodule CustomizationRef do
    use Ecto.Schema
    import Ecto.Changeset

    @primary_key false
    embedded_schema do
      field :key_id, :integer
    end

    def changeset(schema, attrs) do
      schema
      |> cast(attrs, [:key_id])
      |> validate_required([:key_id])
    end
  end

  schema "category" do
    field :enable, :boolean
    field :name, :string
    field :sort_order, :integer
    embeds_many :valid_customizations, CustomizationRef, on_replace: :delete

    timestamps()
  end

  @doc false
  def changeset(category, attrs) do
    category
    |> cast(attrs, [:enable, :name, :sort_order])
    |> cast_embed(:valid_customizations, with: &CustomizationRef.changeset/2)
    |> validate_required([:name])
  end
end

defimpl Jason.Encoder, for: Kaffebase.Catalog.Category do
  def encode(category, opts) do
    valid_customizations =
      category.valid_customizations
      |> List.wrap()
      |> Enum.map(& &1.key_id)

    Jason.Encode.map(
      %{
        id: category.id,
        name: category.name,
        sort_order: category.sort_order,
        enable: category.enable,
        valid_customizations: valid_customizations,
        inserted_at: category.inserted_at,
        updated_at: category.updated_at
      },
      opts
    )
  end
end
