defmodule Kaffebase.EctoTypes.JsonbItems do
  @moduledoc """
  Custom Ecto type for JSONB-stored item snapshots in orders.

  Stores immutable snapshots of ordered items with their customizations.
  Keys are decoded as atoms for pattern matching.

  ## Example

      [
        %{
          item_id: "item_123",
          name: "Latte",
          price: 450,
          category: "beverage",
          customizations: [
            %{key: "size", value: ["large"]},
            %{key: "milk", value: ["oat"]}
          ]
        }
      ]
  """

  use Ecto.Type

  @type item :: %{
          item_id: String.t(),
          name: String.t(),
          price: integer(),
          category: String.t(),
          customizations: [customization()]
        }

  @type customization :: %{
          key: String.t(),
          value: [String.t()]
        }

  @type t :: [item()]

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
