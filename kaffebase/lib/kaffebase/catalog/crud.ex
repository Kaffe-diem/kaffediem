defmodule Kaffebase.Catalog.Crud do
  @moduledoc """
  Shared CRUD helpers for catalog entities.

  Centralizes common Repo access patterns and collection notifications without
  relying on macros so that each ops module stays explicit and easy to override.
  """

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

  def create(schema, attrs, collection) when is_atom(schema) do
    schema
    |> struct()
    |> schema.changeset(attrs)
    |> Repo.insert()
    |> notify_change(collection, "create")
  end

  def update(schema, record, attrs, collection) when is_atom(schema) do
    record
    |> schema.changeset(attrs)
    |> Repo.update()
    |> notify_change(collection, "update")
  end

  def delete(_schema, record, collection) do
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
    CollectionNotifier.broadcast_change(collection, action, record)
    result
  end

  defp notify_change(result, _collection, _action), do: result

  defp notify_delete({:ok, record} = result, collection) do
    CollectionNotifier.broadcast_delete(collection, record.id)
    result
  end

  defp notify_delete(result, _collection), do: result
end
