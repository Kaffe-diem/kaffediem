defmodule Kaffebase.Catalog.Item do
  use Ecto.Schema
  import Ecto.Changeset

  alias Kaffebase.Ids

  @primary_key {:id, :string, autogenerate: false}
  @timestamps_opts [type: :utc_datetime_usec, inserted_at: :created, updated_at: :updated]

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
