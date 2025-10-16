defmodule Kaffebase.Orders.Process.Impl do
  @moduledoc """
  Handles core business logic for order operations.
  Stateless functions that transform order state based on commands/events.
  """

  require Logger

  alias Kaffebase.Orders.Event
  alias Kaffebase.Orders.Events
  alias Kaffebase.Orders.Order
  alias Kaffebase.Repo

  @type state :: %{
          order_id: String.t(),
          customer: String.t() | nil,
          day_id: integer(),
          state: atom(),
          missing_information: boolean(),
          events: [struct()]
        }

  @doc "Initialize state from events"
  def initialize(order_id) do
    events = Event.load_events(order_id)
    replay_events(order_id, events)
  end

  @doc "Change order state"
  def change_state(state, new_state) do
    event = %Events.OrderStateChanged{
      order_id: state.order_id,
      from_state: state.state,
      to_state: new_state,
      timestamp: DateTime.utc_now()
    }

    with {:ok, _} <- Event.append(state.order_id, event),
         {:ok, _} <- persist_state_change(state.order_id, new_state) do
      new_state_map = apply_event(state, event)
      {:ok, new_state_map}
    end
  end

  @doc "Update order metadata"
  def update_order(state, changes) do
    event = %Events.OrderUpdated{
      order_id: state.order_id,
      changes: changes,
      timestamp: DateTime.utc_now()
    }

    with {:ok, _} <- Event.append(state.order_id, event),
         {:ok, _} <- persist_order_update(state.order_id, changes) do
      new_state = apply_event(state, event)
      {:ok, new_state}
    end
  end

  @doc "Delete order"
  def delete_order(state) do
    event = %Events.OrderDeleted{
      order_id: state.order_id,
      timestamp: DateTime.utc_now()
    }

    with {:ok, _} <- Event.append(state.order_id, event),
         {:ok, _} <- delete_from_db(state.order_id) do
      {:ok, state}
    end
  end

  @doc "Get full order representation for broadcast"
  def get_order_for_broadcast(state) do
    Repo.get!(Order, state.order_id)
  end

  # Event Replay

  defp replay_events(order_id, events) do
    initial_state = %{
      order_id: order_id,
      customer: nil,
      day_id: nil,
      state: nil,
      missing_information: false,
      events: []
    }

    Enum.reduce(events, initial_state, &apply_event(&2, &1))
  end

  defp apply_event(state, %Events.OrderPlaced{} = event) do
    %{
      state
      | customer: event.customer,
        day_id: event.day_id,
        state: :received,
        missing_information: event.missing_information,
        events: [event | state.events]
    }
  end

  defp apply_event(state, %Events.OrderStateChanged{} = event) do
    %{state | state: event.to_state, events: [event | state.events]}
  end

  defp apply_event(state, %Events.OrderUpdated{} = event) do
    updated =
      Enum.reduce(event.changes, state, fn {key, value}, acc ->
        Map.put(acc, key, value)
      end)

    %{updated | events: [event | state.events]}
  end

  defp apply_event(state, %Events.OrderDeleted{} = event) do
    %{state | events: [event | state.events]}
  end

  defp apply_event(state, _unknown_event), do: state

  # Persistence

  defp persist_state_change(order_id, new_state) do
    order = Repo.get!(Order, order_id)

    order
    |> Order.changeset(%{state: new_state})
    |> Repo.update()
  end

  defp persist_order_update(order_id, changes) do
    order = Repo.get!(Order, order_id)

    order
    |> Order.changeset(changes)
    |> Repo.update()
  end

  defp delete_from_db(order_id) do
    order = Repo.get!(Order, order_id)
    Repo.delete(order)
  end
end
