defmodule Kaffebase.BroadcastHelpers do
  @moduledoc """
  Shared helpers for broadcasting changes to channels.
  """

  require Logger

  @doc """
  Notifies on successful/failed create or update operations.

  Logs success/failure and calls the broadcast_fn on success.
  """
  def notify_change({:ok, record} = result, collection, action, broadcast_fn) do
    Logger.info("#{String.capitalize(collection)} #{action}: #{record.id}")
    broadcast_fn.(collection, action, record)
    result
  end

  def notify_change({:error, %Ecto.Changeset{} = changeset} = result, collection, action, _broadcast_fn) do
    Logger.warning("#{String.capitalize(collection)} #{action} failed: #{inspect(changeset.errors)}")
    result
  end

  def notify_change(result, _collection, _action, _broadcast_fn), do: result

  @doc """
  Notifies on successful/failed delete operations.

  Logs success/failure and calls the broadcast_fn on success.
  """
  def notify_delete({:ok, record} = result, collection, broadcast_fn) do
    Logger.info("#{String.capitalize(collection)} delete: #{record.id}")
    broadcast_fn.(collection, record)
    result
  end

  def notify_delete({:error, %Ecto.Changeset{} = changeset} = result, collection, _broadcast_fn) do
    Logger.warning("#{String.capitalize(collection)} delete failed: #{inspect(changeset.errors)}")
    result
  end

  def notify_delete(result, _collection, _broadcast_fn), do: result
end
