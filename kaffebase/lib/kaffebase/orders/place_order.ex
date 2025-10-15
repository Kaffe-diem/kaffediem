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
    field(:customer_id, :string)
    field(:missing_information, :boolean, default: false)
    field(:state, Ecto.Enum, values: @states, default: :received)
    field(:items, {:array, :map}, default: [])
  end

  def cast_state(value) when is_atom(value) and value in @states, do: value

  def cast_state(value) when is_binary(value) do
    case String.downcase(value) do
      "received" -> :received
      "production" -> :production
      "completed" -> :completed
      "dispatched" -> :dispatched
      _ -> :received
    end
  end

  def cast_state(_), do: :received

  @type t :: %__MODULE__{
          customer_id: String.t() | nil,
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
    normalized_attrs = normalize_customer_id(attrs)

    schema
    |> cast(normalized_attrs, [:customer_id, :missing_information, :state, :items])
    |> cast_items()
    |> validate_required([:state, :items])
    |> validate_length(:items, min: 1)
  end

  # Normalize customer/customer_id and ensure it's a string
  defp normalize_customer_id(%{customer_id: id} = attrs) when is_integer(id) do
    Map.put(attrs, :customer_id, to_string(id))
  end

  defp normalize_customer_id(%{customer: id} = attrs) when is_binary(id) or is_integer(id) do
    attrs
    |> Map.delete(:customer)
    |> Map.put(:customer_id, to_string(id))
  end

  defp normalize_customer_id(attrs), do: attrs

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

  defp build_item_snapshot(%{item: item_id} = attrs) when is_binary(item_id) do
    with {:ok, item} <- fetch_item(item_id) do
      customizations = build_customizations_snapshot(attrs[:customizations] || [])

      %{
        item_id: item.id,
        name: item.name,
        price: Decimal.to_string(item.price_nok),
        category: item.category,
        customizations: customizations
      }
    else
      _ -> :error
    end
  end

  defp build_item_snapshot(%{item_id: item_id} = attrs) when is_binary(item_id) do
    build_item_snapshot(%{item: item_id, customizations: attrs[:customizations]})
  end

  defp build_item_snapshot(%{item: nil}), do: :error
  defp build_item_snapshot(%{item_id: nil}), do: :error
  defp build_item_snapshot(_), do: :error

  defp build_customizations_snapshot(customizations) when is_list(customizations) do
    customizations
    |> Enum.map(&normalize_customization/1)
    |> Enum.reject(&is_nil/1)
    |> Enum.flat_map(&build_customization_snapshot/1)
  end

  defp build_customizations_snapshot(_), do: []

  defp normalize_customization(%{key: key_id, value: value_ids}) do
    %{key_id: key_id, value_ids: List.wrap(value_ids)}
  end

  defp normalize_customization(%{key_id: key_id, value_ids: value_ids}) do
    %{key_id: key_id, value_ids: List.wrap(value_ids)}
  end

  defp normalize_customization(_), do: nil

  defp build_customization_snapshot(%{key_id: key_id, value_ids: value_ids}) do
    with {:ok, key} <- fetch_customization_key(key_id) do
      value_ids
      |> List.wrap()
      |> Enum.map(fn value_id ->
        case fetch_customization_value(value_id) do
          {:ok, value} ->
            %{
              key_id: key.id,
              key_name: key.name,
              value_id: value.id,
              value_name: value.name,
              price_change: Decimal.to_string(value.price_increment_nok || 0)
            }

          _ ->
            nil
        end
      end)
      |> Enum.reject(&is_nil/1)
    else
      _ -> []
    end
  end

  defp fetch_item(item_id) do
    case Catalog.get_item(item_id) do
      nil -> {:error, :not_found}
      item -> {:ok, item}
    end
  end

  defp fetch_customization_key(key_id) do
    case Catalog.get_customization_key(key_id) do
      nil -> {:error, :not_found}
      key -> {:ok, key}
    end
  end

  defp fetch_customization_value(value_id) do
    case Catalog.get_customization_value(value_id) do
      nil -> {:error, :not_found}
      value -> {:ok, value}
    end
  end
end
