defmodule Kaffebase.CollectionNotifier do
  @moduledoc false
  require Logger

  alias KaffebaseWeb.CollectionChannel

  def broadcast_change(collection, action, record) do
    Logger.debug("CollectionNotifier: #{collection} #{action}")
    CollectionChannel.broadcast_change(collection, action, record)
  end

  def broadcast_delete(collection, record_id) do
    Logger.debug("CollectionNotifier: #{collection} delete #{record_id}")
    CollectionChannel.broadcast_delete(collection, record_id)
  end
end
