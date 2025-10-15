defmodule Kaffebase.Orders.Order.Server do
  @moduledoc """
  GenServer that manages a single order's state and lifecycle.
  """
  use GenServer
  require Logger

  alias Kaffebase.Orders.Process.Impl

  def start_link(order_id) do
    Logger.metadata(order_id: order_id)
    Logger.debug("Starting order process", event: :order_start)
    GenServer.start_link(__MODULE__, order_id, name: via_tuple(order_id))
  end

  defp via_tuple(order_id) do
    {:via, Registry, {Kaffebase.Orders.OrderRegistry, order_id}}
  end

  @impl true
  def init(order_id) do
    Logger.metadata(order_id: order_id)
    Logger.debug("Initializing order process", event: :order_init)
    state = Impl.initialize(order_id)
    {:ok, state}
  end

  @impl true
  def handle_call(:get_state, _from, state) do
    {:reply, {:ok, state}, state}
  end

  @impl true
  def handle_call({:change_state, new_state}, _from, state) do
    case Impl.change_state(state, new_state) do
      {:ok, new_state_map} ->
        order = Impl.get_order_for_broadcast(new_state_map)
        broadcast_change("order", "update", order)
        {:reply, {:ok, new_state_map}, new_state_map}

      {:error, reason} = error ->
        Logger.error("Failed to change state",
          event: :state_change_error,
          reason: inspect(reason)
        )

        {:reply, error, state}
    end
  end

  @impl true
  def handle_call({:update_order, changes}, _from, state) do
    case Impl.update_order(state, changes) do
      {:ok, new_state} ->
        order = Impl.get_order_for_broadcast(new_state)
        broadcast_change("order", "update", order)
        {:reply, {:ok, new_state}, new_state}

      {:error, reason} = error ->
        Logger.error("Failed to update order", event: :update_error, reason: inspect(reason))
        {:reply, error, state}
    end
  end

  @impl true
  def handle_call(:delete_order, _from, state) do
    case Impl.delete_order(state) do
      {:ok, _} ->
        broadcast_delete("order", state.order_id)
        {:stop, :normal, {:ok, state}, state}

      {:error, reason} = error ->
        Logger.error("Failed to delete order", event: :delete_error, reason: inspect(reason))
        {:reply, error, state}
    end
  end

  @impl true
  def terminate(reason, state) do
    Logger.metadata(order_id: state.order_id)
    Logger.debug("Order process terminating", event: :order_terminate, reason: inspect(reason))
    :ok
  end

  defp broadcast_change(collection, action, record) do
    Kaffebase.CollectionNotifier.broadcast_change(collection, action, record)
  end

  defp broadcast_delete(collection, id) do
    Kaffebase.CollectionNotifier.broadcast_delete(collection, id)
  end
end
