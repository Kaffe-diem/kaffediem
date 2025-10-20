defmodule Kaffebase.Catalog.ItemCustomization do
  use Ecto.Schema
  import Ecto.Changeset

  alias Kaffebase.Ids
  alias Kaffebase.EctoTypes.JsonbList

  @primary_key {:id, :string, autogenerate: false}

  schema "item_customization" do
    field :key, :string
    field :value, JsonbList

    timestamps()
  end

  @doc false
  def changeset(item_customization, attrs) do
    item_customization
    |> cast(attrs, [:id, :key, :value])
    |> maybe_put_id()
    |> validate_required([:key])
  end

  defp maybe_put_id(changeset) do
    case fetch_field(changeset, :id) do
      {:data, nil} -> put_change(changeset, :id, Ids.generate())
      {:changes, nil} -> put_change(changeset, :id, Ids.generate())
      _ -> changeset
    end
  end
end

defimpl Jason.Encoder, for: Kaffebase.Catalog.ItemCustomization do
  def encode(customization, opts) do
    Jason.Encode.map(
      %{
        id: customization.id,
        key_id: customization.key,
        value_ids: customization.value || [],
        inserted_at: customization.inserted_at,
        updated_at: customization.updated_at
      },
      opts
    )
  end
end
