defmodule Kaffebase.EctoTypes.JsonbList do
  @moduledoc """
  Custom Ecto type for storing lists of strings as JSON in SQLite.

  ## Examples

      # category.valid_customizations
      ["customization_key_id_1", "customization_key_id_2"]

      # item_customization.value
      ["customization_value_id_1", "customization_value_id_2"]
  """

  use Ecto.Type

  @type t :: [String.t()]

  @impl true
  def type, do: :string

  @impl true
  def cast(list) when is_list(list), do: {:ok, list}
  def cast(nil), do: {:ok, []}
  def cast(_), do: :error

  @impl true
  def load(data) when is_binary(data) do
    case Jason.decode(data) do
      {:ok, decoded} when is_list(decoded) -> {:ok, decoded}
      {:ok, _} -> {:ok, []}
      {:error, _} -> {:ok, []}
    end
  end

  def load(nil), do: {:ok, []}
  def load(_), do: :error

  @impl true
  def dump(list) when is_list(list), do: {:ok, Jason.encode!(list)}
  def dump(nil), do: {:ok, Jason.encode!([])}
  def dump(_), do: :error
end
