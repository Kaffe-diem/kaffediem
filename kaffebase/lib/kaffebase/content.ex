defmodule Kaffebase.Content do
  @moduledoc """
  Content context replacing PocketBase message and status collections.
  """

  import Ecto.Query, warn: false

  alias Kaffebase.CollectionNotifier
  alias Kaffebase.Content.{Message, Status}
  alias Kaffebase.Repo

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

  @spec list_statuses(keyword()) :: [Status.t()]
  def list_statuses(opts \\ []) do
    Status
    |> Repo.all()
    |> maybe_preload(opts)
  end

  @spec get_status!(String.t(), keyword()) :: Status.t()
  def get_status!(id, opts \\ []) do
    Status
    |> Repo.get!(id)
    |> maybe_preload(opts)
  end

  @spec get_singleton_status(keyword()) :: Status.t() | nil
  def get_singleton_status(opts \\ []) do
    Status
    |> limit(1)
    |> Repo.one()
    |> maybe_preload(opts)
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

  defp maybe_preload(nil, _opts), do: nil

  defp maybe_preload(status_or_list, opts) do
    if preload_message?(opts) do
      preload_message(status_or_list)
    else
      status_or_list
    end
  end

  defp preload_message?(opts) do
    opts
    |> Keyword.get(:preload, [])
    |> List.wrap()
    |> Enum.member?(:message)
  end

  defp preload_message(statuses) when is_list(statuses) do
    message_map = fetch_messages(statuses)

    Enum.map(statuses, fn status ->
      expand =
        Map.get(status, :expand, %{}) |> Map.put(:message, Map.get(message_map, status.message))

      Map.put(status, :expand, expand)
    end)
  end

  defp preload_message(%Status{} = status) do
    message_map = fetch_messages([status])

    expand =
      Map.get(status, :expand, %{}) |> Map.put(:message, Map.get(message_map, status.message))

    Map.put(status, :expand, expand)
  end

  defp fetch_messages(statuses) do
    ids =
      statuses
      |> Enum.map(& &1.message)
      |> Enum.reject(&is_nil/1)
      |> Enum.uniq()

    Message
    |> where([m], m.id in ^ids)
    |> Repo.all()
    |> Map.new(&{&1.id, &1})
  end

  defp notify({:ok, record} = result, collection, action) do
    CollectionNotifier.broadcast_change(collection, action, record)
    result
  end

  defp notify(result, _collection, _action), do: result

  defp notify_delete({:ok, record} = result, collection) do
    CollectionNotifier.broadcast_delete(collection, record.id)
    result
  end

  defp notify_delete(result, _collection), do: result
end
