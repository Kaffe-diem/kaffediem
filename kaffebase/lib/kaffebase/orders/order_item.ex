defmodule Kaffebase.Orders.OrderItem do
  use Ecto.Schema
  import Ecto.Changeset

  alias Kaffebase.Catalog.Item
  alias Kaffebase.EctoTypes.StringList
  alias Kaffebase.Ids

  @primary_key {:id, :string, autogenerate: false}
  @foreign_key_type :string
  @timestamps_opts [type: :utc_datetime_usec, inserted_at: :created, updated_at: :updated]

  schema "order_item" do
    field :item, :string

    belongs_to :item_record, Item,
      define_field: false,
      foreign_key: :item,
      references: :id

    field :customization, StringList, default: []

    timestamps()
  end

  @doc false
  def changeset(order_item, attrs) do
    order_item
    |> cast(attrs, [:id, :item, :customization])
    |> maybe_put_id()
    |> validate_required([:item])
  end

  defp maybe_put_id(changeset) do
    case fetch_field(changeset, :id) do
      {:data, nil} -> put_change(changeset, :id, Ids.generate())
      {:changes, nil} -> put_change(changeset, :id, Ids.generate())
      _ -> changeset
    end
  end
end
