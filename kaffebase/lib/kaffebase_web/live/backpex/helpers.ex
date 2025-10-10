defmodule KaffebaseWeb.Backpex.Helpers do
  @moduledoc false

  # SQLite cannot handle `DISTINCT` across multiple columns. Backpex injects a
  # distinct clause when preloading associations, which breaks `:show`/`:edit`
  # queries on SQLite-backed projects. We strip that clause for those actions as
  # a workaround. Original error: "DISTINCT with multiple columns is not supported by SQLite3".
  # TODO: This is sort of a hack. Should be removed, especially if we switch out the database.
  import Ecto.Query, only: [exclude: 2]

  @doc """
  Removes the generated DISTINCT clause for actions that fetch a single entry.
  """
  def item_query_without_distinct(query, live_action, _assigns) when live_action in [:show, :edit] do
    exclude(query, :distinct)
  end

  def item_query_without_distinct(query, _live_action, _assigns), do: query
end
