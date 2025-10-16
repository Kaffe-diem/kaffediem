defmodule Kaffebase.EctoTypes.JsonbList do
  @moduledoc """
  Custom Ecto type for storing lists as JSON in SQLite.
  Handles automatic encoding/decoding of string arrays.
  """

  use Ecto.Type

  def type, do: :string

  def cast(list) when is_list(list), do: {:ok, list}
  def cast(nil), do: {:ok, []}
  def cast(_), do: :error

  def load(data) when is_binary(data) do
    case Jason.decode(data) do
      {:ok, decoded} when is_list(decoded) -> {:ok, decoded}
      {:ok, _} -> {:ok, []}
      {:error, _} -> {:ok, []}
    end
  end

  def load(nil), do: {:ok, []}
  def load(_), do: :error

  def dump(list) when is_list(list), do: {:ok, Jason.encode!(list)}
  def dump(nil), do: {:ok, Jason.encode!([])}
  def dump(_), do: :error
end
