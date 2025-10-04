defmodule Kaffebase.CollectionNotifier do
  @moduledoc false

  alias KaffebaseWeb.CollectionChannel

  def broadcast_change(collection, action, record) do
    CollectionChannel.broadcast_change(collection, action, record)
  end

  def broadcast_delete(collection, record_id) do
    CollectionChannel.broadcast_delete(collection, record_id)
  end
end
