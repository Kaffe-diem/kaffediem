defmodule Kaffebase.Content do
  @moduledoc """
  Content context replacing PocketBase message and status collections.
  """

  require Logger
  import Ecto.Query, warn: false

  alias Kaffebase.Content.{Message, Status}
  alias Kaffebase.Repo
  alias KaffebaseWeb.CollectionChannel

  # Messages -----------------------------------------------------------------

  @spec list_messages(keyword()) :: [Message.t()]
  def list_messages(opts \\ []) do
    Message
    |> maybe_apply_order(opts[:order_by] || [asc: :title])
    |> Repo.all()
  end

  @spec get_message!(String.t()) :: Message.t()
  def get_message!(id), do: Repo.get!(Message, id)

  @spec create_message(map()) :: {:ok, Message.t()} | {:error, Ecto.Changeset.t()}
  def create_message(attrs \\ %{}) do
    %Message{}
    |> Message.changeset(attrs)
    |> Repo.insert()
    |> notify("message", "create")
  end

  @spec update_message(Message.t(), map()) :: {:ok, Message.t()} | {:error, Ecto.Changeset.t()}
  def update_message(%Message{} = message, attrs) do
    message
    |> Message.changeset(attrs)
    |> Repo.update()
    |> notify("message", "update")
  end

  @spec delete_message(Message.t()) :: {:ok, Message.t()} | {:error, Ecto.Changeset.t()}
  def delete_message(%Message{} = message) do
    message
    |> Repo.delete()
    |> notify_delete("message")
  end

  @spec change_message(Message.t(), map()) :: Ecto.Changeset.t()
  def change_message(%Message{} = message, attrs \\ %{}), do: Message.changeset(message, attrs)

  # Status -------------------------------------------------------------------

  @spec list_statuses() :: [Status.t()]
  def list_statuses do
    Repo.all(Status)
  end

  @spec get_status!(String.t()) :: Status.t()
  def get_status!(id) do
    Repo.get!(Status, id)
  end

  @spec get_singleton_status() :: Status.t() | nil
  def get_singleton_status do
    Status
    |> limit(1)
    |> Repo.one()
  end

  @spec create_status(map()) :: {:ok, Status.t()} | {:error, Ecto.Changeset.t()}
  def create_status(attrs \\ %{}) do
    %Status{}
    |> Status.changeset(attrs)
    |> Repo.insert()
    |> notify("status", "create")
  end

  @spec update_status(Status.t(), map()) :: {:ok, Status.t()} | {:error, Ecto.Changeset.t()}
  def update_status(%Status{} = status, attrs) do
    status
    |> Status.changeset(attrs)
    |> Repo.update()
    |> notify("status", "update")
  end

  @spec delete_status(Status.t()) :: {:ok, Status.t()} | {:error, Ecto.Changeset.t()}
  def delete_status(%Status{} = status) do
    status
    |> Repo.delete()
    |> notify_delete("status")
  end

  @spec change_status(Status.t(), map()) :: Ecto.Changeset.t()
  def change_status(%Status{} = status, attrs \\ %{}), do: Status.changeset(status, attrs)

  # Helpers ------------------------------------------------------------------

  defp maybe_apply_order(query, nil), do: query
  defp maybe_apply_order(query, []), do: query

  defp maybe_apply_order(query, orderings), do: order_by(query, ^orderings)

  defp notify({:ok, record} = result, collection, action) do
    Logger.info("#{String.capitalize(collection)} #{action}: #{record.id}")
    broadcast_change(collection, action, record)
    result
  end

  defp notify({:error, %Ecto.Changeset{} = changeset} = result, collection, action) do
    Logger.warning("#{String.capitalize(collection)} #{action} failed: #{inspect(changeset.errors)}")
    result
  end

  defp notify(result, _collection, _action), do: result

  defp notify_delete({:ok, record} = result, collection) do
    Logger.info("#{String.capitalize(collection)} delete: #{record.id}")
    broadcast_delete(collection, record)
    result
  end

  defp notify_delete({:error, %Ecto.Changeset{} = changeset} = result, collection) do
    Logger.warning("#{String.capitalize(collection)} delete failed: #{inspect(changeset.errors)}")
    result
  end

  defp notify_delete(result, _collection), do: result

  defp broadcast_change(collection, _action, _record)
       when collection in ["message", "status"] do
    CollectionChannel.broadcast_change("status", "reload", %{})
  end

  defp broadcast_change(_collection, _action, _record), do: :ok

  defp broadcast_delete(collection, _record)
       when collection in ["message", "status"] do
    CollectionChannel.broadcast_change("status", "reload", %{})
  end

  defp broadcast_delete(_collection, _record), do: :ok
end
