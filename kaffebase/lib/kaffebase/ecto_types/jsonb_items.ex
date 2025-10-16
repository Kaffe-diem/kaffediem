defmodule Kaffebase.EctoTypes.JsonbItems do
  @moduledoc """
  Custom Ecto type for JSONB-stored item snapshots.

  Automatically encodes/decodes between Elixir lists and JSON strings.
  Each item is a map with keys: item_id, name, price, category, customizations.
  """

  use Ecto.Type

  @impl true
  def type, do: :string

  @impl true
  def cast(items) when is_list(items), do: {:ok, items}
  def cast(_), do: :error

  @impl true
  def load(nil), do: {:ok, []}

  def load(data) when is_binary(data) do
    case Jason.decode(data, keys: :atoms) do
      {:ok, decoded} when is_list(decoded) -> {:ok, decoded}
      {:ok, _} -> {:ok, []}
      {:error, _} -> {:ok, []}
    end
  end

  @impl true
  def dump(items) when is_list(items) do
    {:ok, Jason.encode!(items)}
  end

  def dump(_), do: :error
end
