defmodule Kaffebase.Orders.PlaceOrder do
  @moduledoc """
  Command to place an order - builds denormalized snapshots from catalog.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Kaffebase.Catalog
  alias Kaffebase.Orders.Order

  @states Order.states()

  @primary_key false

  embedded_schema do
    field(:customer_id, :integer)
    field(:missing_information, :boolean, default: false)
    field(:state, Ecto.Enum, values: @states, default: :received)
    field(:items, {:array, :map}, default: [])
  end

  @type t :: %__MODULE__{
          customer_id: integer() | nil,
          missing_information: boolean(),
          state: Order.state(),
          items: [map()]
        }

  @spec new(map()) :: {:ok, t()} | {:error, Ecto.Changeset.t()}
  def new(attrs) when is_map(attrs) do
    %__MODULE__{}
    |> changeset(attrs)
    |> apply_action(:insert)
  end

  defp changeset(schema, attrs) do
    schema
    |> cast(attrs, [:customer_id, :missing_information, :state, :items])
    |> cast_items()
    |> validate_required([:state, :items])
    |> validate_length(:items, min: 1)
  end

  defp cast_items(changeset) do
    raw_items = get_change(changeset, :items, [])
    normalized = normalize_items(raw_items)

    {items, errors} =
      normalized
      |> Enum.map(&build_item_snapshot/1)
      |> Enum.split_with(&(&1 != :error))

    items = Enum.reject(items, &is_nil/1)

    changeset = put_change(changeset, :items, items)

    cond do
      errors != [] ->
        add_error(changeset, :items, "is invalid")

      items == [] ->
        add_error(changeset, :items, "is invalid")

      true ->
        changeset
    end
  end

  defp normalize_items(items) when is_list(items), do: items
  defp normalize_items(_), do: []

  defp build_item_snapshot(%{item: item_id, customizations: customizations}) when is_binary(item_id) do
    case Catalog.get_item(item_id) do
      nil -> :error
      item -> snapshot_item(item, customizations)
    end
  end

  defp build_item_snapshot(%{item: item_id}) when is_binary(item_id) do
    build_item_snapshot(%{item: item_id, customizations: []})
  end

  defp build_item_snapshot(_), do: :error

  defp snapshot_item(item, customizations) do
    %{
      item_id: item.id,
      name: item.name,
      price: Decimal.to_string(item.price_nok),
      category: item.category,
      customizations: build_customizations_snapshot(customizations)
    }
  end

  defp build_customizations_snapshot(customizations) when is_list(customizations) do
    Enum.flat_map(customizations, fn
      %{key: key_id, value: value_ids} ->
        snapshot_customization(key_id, List.wrap(value_ids))

      _ ->
        []
    end)
  end

  defp build_customizations_snapshot(_), do: []

  defp snapshot_customization(key_id, value_ids) do
    case Catalog.get_customization_key(key_id) do
      nil ->
        []

      key ->
        value_ids
        |> Enum.map(fn value_id ->
          case Catalog.get_customization_value(value_id) do
            nil -> nil
            value -> snapshot_customization_value(key, value)
          end
        end)
        |> Enum.reject(&is_nil/1)
    end
  end

  defp snapshot_customization_value(key, value) do
    %{
      key_id: key.id,
      key_name: key.name,
      value_id: value.id,
      value_name: value.name,
      price_change: Decimal.to_string(value.price_increment_nok || 0)
    }
  end
end
