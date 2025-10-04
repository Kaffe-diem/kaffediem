defmodule Kaffebase.ContentFixtures do
  @moduledoc false

  alias Kaffebase.Content

  def unique_string(prefix) do
    unique = System.unique_integer([:positive, :monotonic])
    "#{prefix}_#{unique}"
  end

  def message_fixture(attrs \\ %{}) do
    defaults = %{
      title: unique_string("Title"),
      subtitle: unique_string("Subtitle")
    }

    {:ok, message} =
      attrs
      |> Enum.into(defaults)
      |> Content.create_message()

    message
  end

  def status_fixture(attrs \\ %{}) do
    message = Map.get_lazy(attrs, :message, fn -> message_fixture() end)

    defaults = %{
      message: message.id,
      open: false,
      show_message: false
    }

    {:ok, status} =
      attrs
      |> Map.delete(:message)
      |> Enum.into(defaults)
      |> Content.create_status()

    status
  end
end
