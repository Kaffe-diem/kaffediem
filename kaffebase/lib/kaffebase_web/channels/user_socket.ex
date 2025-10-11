defmodule KaffebaseWeb.UserSocket do
  use Phoenix.Socket

  channel "collection:*", KaffebaseWeb.CollectionChannel

  def connect(_params, socket, _connect_info) do
    {:ok, socket}
  end

  def id(_socket), do: nil
end
