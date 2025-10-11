defmodule Kaffebase.EctoTypes.StringList do
  @moduledoc """
  Casts JSON array columns holding record id lists into native string lists.
  """

  use Ecto.Type

  @impl true
  def type, do: :map

  @impl true
  def cast(value) when is_list(value) do
    if Enum.all?(value, &is_binary/1), do: {:ok, value}, else: :error
  end

  def cast(value) when is_binary(value) do
    with {:ok, decoded} <- Jason.decode(value),
         {:ok, list} <- cast(decoded) do
      {:ok, list}
    else
      _ -> :error
    end
  end

  def cast(_), do: :error

  @impl true
  def load(value), do: cast(value)

  @impl true
  def dump(value) when is_list(value) do
    if Enum.all?(value, &is_binary/1), do: {:ok, value}, else: :error
  end

  def dump(value) when is_binary(value) do
    with {:ok, decoded} <- Jason.decode(value),
         {:ok, list} <- cast(decoded) do
      {:ok, list}
    else
      _ -> :error
    end
  end

  def dump(_), do: :error
end
