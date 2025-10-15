defmodule Kaffebase.Orders.Process do
  @moduledoc """
  Public API for order operations.
  """
  require Logger

  @doc "Get current order state"
  def get_state(order_id) do
    GenServer.call(via_tuple(order_id), :get_state)
  end

  @doc "Update order state"
  def change_state(order_id, new_state) do
    GenServer.call(via_tuple(order_id), {:change_state, new_state})
  end

  @doc "Update order metadata"
  def update_order(order_id, changes) do
    GenServer.call(via_tuple(order_id), {:update_order, changes})
  end

  @doc "Delete order"
  def delete_order(order_id) do
    GenServer.call(via_tuple(order_id), :delete_order)
  end

  defp via_tuple(order_id) do
    {:via, Registry, {Kaffebase.Orders.OrderRegistry, order_id}}
  end

  @doc """
  Gets the PID of an order process by order_id.
  Returns {:ok, pid} if exists, :error otherwise.
  """
  def get_order_pid(order_id) do
    case Registry.lookup(Kaffebase.Orders.OrderRegistry, order_id) do
      [{pid, _}] -> {:ok, pid}
      [] -> :error
    end
  end
end
