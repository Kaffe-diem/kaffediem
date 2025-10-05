defmodule Kaffebase.Orders.Order do
  use Ecto.Schema
  import Ecto.Changeset

  alias Kaffebase.EctoTypes.StringList
  alias Kaffebase.Ids

  @primary_key {:id, :string, autogenerate: false}
  @timestamps_opts [type: :utc_datetime_usec, inserted_at: :created, updated_at: :updated]

  schema "order" do
    field :customer, :string
    field :day_id, :integer, source: :day_id
    field :items, StringList, default: []
    field :missing_information, :boolean, source: :missing_information

    field :state, Ecto.Enum,
      values: [:received, :production, :completed, :dispatched],
      source: :state

    timestamps()
  end

  @doc false
  def changeset(order, attrs) do
    order
    |> cast(attrs, [:id, :customer, :day_id, :items, :missing_information, :state])
    |> maybe_put_id()
    |> validate_required([:items, :state])
  end

  defp maybe_put_id(changeset) do
    case fetch_field(changeset, :id) do
      {:data, nil} -> put_change(changeset, :id, Ids.generate())
      {:changes, nil} -> put_change(changeset, :id, Ids.generate())
      _ -> changeset
    end
  end
end
