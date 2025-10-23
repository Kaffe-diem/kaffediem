defmodule Kaffebase.Catalog.Category do
  use Ecto.Schema
  import Ecto.Changeset

  alias Kaffebase.Ids
  alias Kaffebase.EctoTypes.JsonbList

  @primary_key {:id, :string, autogenerate: false}

  schema "category" do
    field :enable, :boolean
    field :name, :string
    field :sort_order, :integer
    field :valid_customizations, JsonbList

    timestamps()
  end

  @doc false
  def changeset(category, attrs) do
    category
    |> cast(attrs, [:id, :enable, :name, :sort_order, :valid_customizations])
    |> maybe_put_id()
    |> validate_required([:name])
  end

  defp maybe_put_id(changeset) do
    case fetch_field(changeset, :id) do
      {:data, nil} -> put_change(changeset, :id, Ids.generate())
      {:changes, nil} -> put_change(changeset, :id, Ids.generate())
      _ -> changeset
    end
  end
end

defimpl Jason.Encoder, for: Kaffebase.Catalog.Category do
  def encode(category, opts) do
    Jason.Encode.map(
      %{
        id: category.id,
        name: category.name,
        sort_order: category.sort_order,
        enable: category.enable,
        valid_customizations: category.valid_customizations || [],
        inserted_at: category.inserted_at,
        updated_at: category.updated_at
      },
      opts
    )
  end
end
