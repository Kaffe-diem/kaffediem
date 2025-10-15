defmodule Kaffebase.Orders.OrderSupervisor do
  @moduledoc """
  DynamicSupervisor that manages Process instances.

  Starts one process per order. Max 100 concurrent orders.
  """
  use DynamicSupervisor
  require Logger

  alias Kaffebase.Orders.Order.Server

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    DynamicSupervisor.init(
      strategy: :one_for_one,
      max_children: 100
    )
  end

  @doc """
  Starts an Process for the given order_id.
  Returns {:ok, pid} or {:error, reason}.
  """
  def start_order(order_id) do
    case lookup_order(order_id) do
      {:ok, pid} ->
        Logger.debug("Process already running for #{order_id}")
        {:ok, pid}

      :error ->
        Logger.debug("Starting new Process for #{order_id}")

        case DynamicSupervisor.start_child(__MODULE__, {Server, order_id}) do
          {:ok, pid} -> {:ok, pid}
          {:error, {:already_started, pid}} -> {:ok, pid}
          error -> error
        end
    end
  end

  @doc """
  Stops the Process for the given order_id.
  """
  def stop_order(order_id) do
    case lookup_order(order_id) do
      {:ok, pid} ->
        DynamicSupervisor.terminate_child(__MODULE__, pid)

      :error ->
        :ok
    end
  end

  @doc """
  Looks up an Process by order_id.
  Returns {:ok, pid} or :error.
  """
  def lookup_order(order_id) do
    case Registry.lookup(Kaffebase.Orders.OrderRegistry, order_id) do
      [{pid, _}] -> {:ok, pid}
      [] -> :error
    end
  end
end
