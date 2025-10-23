defmodule KaffebaseWeb.ChannelCase do
  @moduledoc """
  Test case module for channel tests with SQL sandbox support.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      import Phoenix.ChannelTest

      @endpoint KaffebaseWeb.Endpoint

      import KaffebaseWeb.ChannelCase
    end
  end

  setup tags do
    Kaffebase.DataCase.setup_sandbox(tags)
    :ok
  end
end
