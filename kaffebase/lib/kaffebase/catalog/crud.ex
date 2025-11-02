defmodule Kaffebase.Catalog.Crud do
  @moduledoc """
  Shared CRUD helpers for catalog entities.

  Centralizes common Repo access patterns and collection notifications without
  relying on macros so that each ops module stays explicit and easy to override.
  """

  require Logger
  import Ecto.Query, warn: false

  alias Kaffebase.{BroadcastHelpers, Repo}
  alias KaffebaseWeb.CollectionChannel

  @default_order [asc: :sort_order, asc: :name]

  @doc """
  Returns all records for the given `schema`.
  """
  def list(schema, opts \\ [], default_order \\ @default_order) when is_atom(schema) do
    schema
    |> maybe_apply_order(opts[:order_by] || default_order)
    |> Repo.all()
  end

  def get(schema, id) when is_atom(schema), do: Repo.get(schema, id)
  def get!(schema, id) when is_atom(schema), do: Repo.get!(schema, id)

  def create(schema, attrs) when is_atom(schema) do
    collection = schema_source(schema)

    schema
    |> struct()
    |> schema.changeset(attrs)
    |> Repo.insert()
    |> notify_change(collection, "create")
  end

  def update(schema, record, attrs) when is_atom(schema) do
    collection = schema_source(schema)

    record
    |> schema.changeset(attrs)
    |> Repo.update()
    |> notify_change(collection, "update")
  end

  def delete(schema, record) when is_atom(schema) do
    collection = schema_source(schema)

    record
    |> Repo.delete()
    |> notify_delete(collection)
  end

  defp maybe_apply_order(query, nil), do: query
  defp maybe_apply_order(query, []), do: query

  defp maybe_apply_order(query, orderings) when is_list(orderings) do
    order_by(query, ^orderings)
  end

  defp notify_change(result, collection, action) do
    BroadcastHelpers.notify_change(result, collection, action, &broadcast_change/3)
  end

  defp notify_delete(result, collection) do
    BroadcastHelpers.notify_delete(result, collection, &broadcast_delete/2)
  end

  defp schema_source(schema) do
    schema.__schema__(:source)
  end

  # These collections are part of the menu structure, so notify menu subscribers
  defp broadcast_change(collection, _action, _record)
       when collection in ["category", "item", "customization_key", "customization_value"] do
    menu_data = KaffebaseWeb.CollectionChannel.load_menu()
    CollectionChannel.broadcast_change("menu", "update", menu_data)
  end

  defp broadcast_change(_collection, _action, _record), do: :ok

  defp broadcast_delete(collection, _record)
       when collection in ["category", "item", "customization_key", "customization_value"] do
    menu_data = KaffebaseWeb.CollectionChannel.load_menu()
    CollectionChannel.broadcast_change("menu", "update", menu_data)
  end

  defp broadcast_delete(_collection, _record), do: :ok
end
