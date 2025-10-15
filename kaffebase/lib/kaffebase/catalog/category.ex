defmodule Kaffebase.Catalog.Category do
  use Ecto.Schema
  import Ecto.Changeset

  alias Kaffebase.EctoTypes.StringList
  alias Kaffebase.Ids

  @primary_key {:id, :string, autogenerate: false}
  @timestamps_opts [type: :utc_datetime_usec, inserted_at: :created, updated_at: :updated]

  schema "category" do
    field :enable, :boolean
    field :name, :string
    field :sort_order, :integer
    field :valid_customizations, StringList, default: []

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
        created: category.created,
        updated: category.updated
      },
      opts
    )
  end
end
