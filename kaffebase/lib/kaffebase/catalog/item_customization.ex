defmodule Kaffebase.Catalog.ItemCustomization do
  use Ecto.Schema
  import Ecto.Changeset

  alias Kaffebase.EctoTypes.StringList
  alias Kaffebase.Ids

  @primary_key {:id, :string, autogenerate: false}
  @timestamps_opts [type: :utc_datetime_usec, inserted_at: :created, updated_at: :updated]

  schema "item_customization" do
    field :key, :string
    field :value, StringList, default: []

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
