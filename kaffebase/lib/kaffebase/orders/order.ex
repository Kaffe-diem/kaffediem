defmodule Kaffebase.Orders.Order do
  use Ecto.Schema
  import Ecto.Changeset

  alias Kaffebase.EctoTypes.JsonbItems
  alias Kaffebase.Ids

  @states [:received, :production, :completed, :dispatched]
  @primary_key {:id, :string, autogenerate: false}
  @timestamps_opts [type: :utc_datetime_usec, inserted_at: :created, updated_at: :updated]

  schema "order" do
    field :customer_id, :integer
    field :day_id, :integer
    field :items, JsonbItems, source: :items_data
    field :missing_information, :boolean

    field :state, Ecto.Enum, values: @states

    timestamps()
  end

  @doc false
  def changeset(order, attrs) do
    order
    |> cast(attrs, [:id, :customer_id, :day_id, :items, :missing_information, :state])
    |> maybe_put_id()
    |> validate_required([:state])
  end

  def states, do: @states

  defp maybe_put_id(changeset) do
    case fetch_field(changeset, :id) do
      {:data, nil} -> put_change(changeset, :id, Ids.generate())
      {:changes, nil} -> put_change(changeset, :id, Ids.generate())
      _ -> changeset
    end
  end
end

defimpl Jason.Encoder, for: Kaffebase.Orders.Order do
  def encode(order, opts) do
    Jason.Encode.map(
      %{
        id: order.id,
        customer_id: order.customer_id,
        day_id: order.day_id,
        state: order.state,
        missing_information: order.missing_information,
        items: order.items || [],
        created: order.created,
        updated: order.updated
      },
      opts
    )
  end
end
