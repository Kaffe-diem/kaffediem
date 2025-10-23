defmodule Kaffebase.Catalog.Crud do
  @moduledoc """
  Shared CRUD helpers for catalog entities.

  Centralizes common Repo access patterns and collection notifications without
  relying on macros so that each ops module stays explicit and easy to override.
  """

  require Logger
  import Ecto.Query, warn: false

  alias Kaffebase.CollectionNotifier
  alias Kaffebase.Repo

  @default_order [asc: :sort_order, asc: :name]

  @doc """
  Returns all records for the given `schema`.

  Supports optional filtering by including `{:filter, {field, value}}` entries in `opts`.
  """
  def list(schema, opts \\ [], default_order \\ @default_order) when is_atom(schema) do
    schema
    |> maybe_apply_filters(opts)
    |> maybe_apply_order(opts[:order_by] || default_order)
    |> Repo.all()
  end

  def get(schema, id) when is_atom(schema), do: Repo.get(schema, id)
  def get!(schema, id) when is_atom(schema), do: Repo.get!(schema, id)

  def create(schema, attrs, collection \\ nil) when is_atom(schema) do
    collection = collection || schema_source(schema)

    schema
    |> struct()
    |> schema.changeset(attrs)
    |> Repo.insert()
    |> notify_change(collection, "create")
  end

  def update(schema, record, attrs, collection \\ nil) when is_atom(schema) do
    collection = collection || schema_source(schema)

    record
    |> schema.changeset(attrs)
    |> Repo.update()
    |> notify_change(collection, "update")
  end

  def delete(schema, record, collection \\ nil) when is_atom(schema) do
    collection = collection || schema_source(schema)

    record
    |> Repo.delete()
    |> notify_delete(collection)
  end

  def change(schema, record, attrs \\ %{}) when is_atom(schema) do
    schema.changeset(record, attrs)
  end

  defp maybe_apply_filters(query, opts) do
    opts
    |> Keyword.get_values(:filter)
    |> Enum.reduce(query, fn
      nil, q ->
        q

      {field, value}, q ->
        where(q, [..., r], field(r, ^field) == ^value)

      filters, q when is_list(filters) ->
        Enum.reduce(filters, q, fn
          {field, value}, inner_q -> where(inner_q, [..., r], field(r, ^field) == ^value)
          _, inner_q -> inner_q
        end)

      _, q ->
        q
    end)
  end

  defp maybe_apply_order(query, nil), do: query
  defp maybe_apply_order(query, []), do: query

  defp maybe_apply_order(query, orderings) when is_list(orderings) do
    order_by(query, ^orderings)
  end

  defp notify_change({:ok, record} = result, collection, action) do
    Logger.info("#{String.capitalize(collection)} #{action}: #{record.id}")
    CollectionNotifier.broadcast_change(collection, action, record)

    # Also broadcast to semantic channels
    broadcast_to_semantic_channel(collection, action, record)

    result
  end

  defp notify_change({:error, %Ecto.Changeset{} = changeset} = result, collection, action) do
    Logger.warning("#{String.capitalize(collection)} #{action} failed: #{inspect(changeset.errors)}")
    result
  end

  defp notify_change(result, _collection, _action), do: result

  defp notify_delete({:ok, record} = result, collection) do
    Logger.info("#{String.capitalize(collection)} delete: #{record.id}")
    CollectionNotifier.broadcast_delete(collection, record.id)

    # Also broadcast to semantic channels
    broadcast_to_semantic_channel(collection, "delete", record)

    result
  end

  defp notify_delete({:error, %Ecto.Changeset{} = changeset} = result, collection) do
    Logger.warning("#{String.capitalize(collection)} delete failed: #{inspect(changeset.errors)}")
    result
  end

  defp notify_delete(result, _collection), do: result

  defp schema_source(schema) do
    schema.__schema__(:source)
  end

  # Map collection changes to semantic channels
  defp broadcast_to_semantic_channel(collection, _action, _record)
       when collection in ["category", "item", "customization_key", "customization_value"] do
    # Reload and broadcast the entire menu
    CollectionNotifier.broadcast_change("menu", "reload", %{})
  end

  defp broadcast_to_semantic_channel(_collection, _action, _record), do: :ok
end
