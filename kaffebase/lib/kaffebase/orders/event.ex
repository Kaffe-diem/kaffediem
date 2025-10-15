defmodule Kaffebase.Orders.Event do
  @moduledoc """
  Persistent event log for orders.
  """
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  alias Kaffebase.Ids
  alias Kaffebase.Orders.Events
  alias Kaffebase.Repo

  @primary_key {:id, :string, autogenerate: false}

  schema "order_events" do
    field :aggregate_id, :string
    field :event_type, :string
    field :event_data, :string
    field :timestamp, :utc_datetime_usec
    field :sequence, :integer
  end

  @doc false
  def changeset(event, attrs) do
    event
    |> cast(attrs, [:id, :aggregate_id, :event_type, :event_data, :timestamp, :sequence])
    |> maybe_put_id()
    |> validate_required([:aggregate_id, :event_type, :event_data, :timestamp, :sequence])
  end

  @doc """
  Appends an event to the log.
  """
  def append(aggregate_id, event_struct) do
    timestamp = DateTime.utc_now()
    event_type = event_struct.__struct__ |> Module.split() |> List.last()
    event_data = Jason.encode!(Map.from_struct(event_struct))

    sequence = next_sequence(aggregate_id)

    %__MODULE__{}
    |> changeset(%{
      aggregate_id: aggregate_id,
      event_type: event_type,
      event_data: event_data,
      timestamp: timestamp,
      sequence: sequence
    })
    |> Repo.insert()
  end

  @doc """
  Loads all events for an aggregate in sequence order.
  """
  def load_events(aggregate_id) do
    __MODULE__
    |> where([e], e.aggregate_id == ^aggregate_id)
    |> order_by([e], asc: e.sequence)
    |> Repo.all()
    |> Enum.map(&deserialize_event/1)
  end

  defp next_sequence(aggregate_id) do
    result =
      __MODULE__
      |> where([e], e.aggregate_id == ^aggregate_id)
      |> select([e], max(e.sequence))
      |> Repo.one()

    case result do
      nil -> 1
      seq -> seq + 1
    end
  end

  defp deserialize_event(%__MODULE__{event_type: type, event_data: data}) do
    module = Module.concat([Events, type])
    decoded = Jason.decode!(data, keys: :atoms)

    decoded
    |> Map.put(:timestamp, decode_timestamp(decoded.timestamp))
    |> then(&struct(module, &1))
  end

  defp decode_timestamp(timestamp) when is_binary(timestamp) do
    {:ok, dt, _} = DateTime.from_iso8601(timestamp)
    dt
  end

  defp decode_timestamp(%DateTime{} = dt), do: dt

  defp maybe_put_id(changeset) do
    case fetch_field(changeset, :id) do
      {:data, nil} -> put_change(changeset, :id, Ids.generate())
      {:changes, nil} -> put_change(changeset, :id, Ids.generate())
      _ -> changeset
    end
  end
end
