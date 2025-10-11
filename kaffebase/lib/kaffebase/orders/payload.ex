defmodule Kaffebase.Orders.Payload do
  @moduledoc """
  Normalizes order params into data structures suited for the Orders context.
  """

  alias Kaffebase.Orders.Order

  @states Order.states()

  @type attrs :: map()

  @spec normalize_new(attrs()) :: %{
          customer_id: String.t() | nil,
          missing_information: boolean(),
          state: Order.state(),
          items: [map()]
        }
  def normalize_new(attrs) when is_map(attrs) do
    %{
      customer_id: customer_id(attrs),
      missing_information: missing_information(attrs, false),
      state: cast_state(fetch(attrs, :state, :received)),
      items: normalize_items(fetch(attrs, :items, []))
    }
  end

  @spec normalize_update(attrs(), Order.state()) :: map()
  def normalize_update(attrs, default_state) when is_map(attrs) do
    items_value = fetch(attrs, :items)

    %{}
    |> maybe_put(:customer, customer_id(attrs))
    |> maybe_put(:missing_information, missing_information_optional(attrs))
    |> maybe_put(:items, normalize_id_list(items_value))
    |> maybe_put(:state, cast_state(fetch(attrs, :state, default_state)))
  end

  @spec customer_id(attrs()) :: String.t() | nil
  def customer_id(attrs) do
    fetch_id(attrs, :customer_id) || fetch_id(attrs, :customer)
  end

  @spec missing_information(attrs(), boolean()) :: boolean()
  def missing_information(attrs, default) do
    attrs
    |> fetch(:missing_information)
    |> case do
      nil -> default
      value -> to_boolean(value)
    end
  end

  @spec missing_information_optional(attrs()) :: boolean() | nil
  def missing_information_optional(attrs) do
    case fetch(attrs, :missing_information) do
      nil -> nil
      value -> to_boolean(value)
    end
  end

  @spec cast_state(term(), Order.state()) :: Order.state()
  def cast_state(value, default) do
    cond do
      is_atom(value) and value in @states -> value
      is_nil(value) -> default
      is_binary(value) -> cast_state_from_string(value, default)
      true -> default
    end
  end

  @spec cast_state(term()) :: Order.state()
  def cast_state(value), do: cast_state(value, :received)

  defp cast_state_from_string(value, default) do
    case String.downcase(value) do
      "received" -> :received
      "production" -> :production
      "completed" -> :completed
      "dispatched" -> :dispatched
      _ -> default
    end
  end

  @spec normalize_id_list(term()) :: [String.t()] | nil
  def normalize_id_list(nil), do: nil

  def normalize_id_list(value) do
    value
    |> List.wrap()
    |> Enum.map(&extract_id/1)
    |> Enum.reject(&is_nil/1)
  end

  @spec normalize_items(term()) :: [map()]
  def normalize_items(items) do
    items
    |> List.wrap()
    |> Enum.reject(&is_nil/1)
    |> Enum.map(&normalize_item/1)
    |> Enum.reject(&(&1 == :invalid))
  end

  # --------------------------------------------------------------------------
  # Internal helpers

  defp normalize_item(item) when is_binary(item) do
    %{existing_order_item_id: item, customizations: []}
  end

  defp normalize_item(%{} = attrs) do
    existing_id =
      fetch_id(attrs, :order_item_id) ||
        fetch_id(attrs, :order_item) ||
        fetch_id(attrs, :existing_order_item_id)

    item_id = fetch_id(attrs, :item_id) || fetch_id(attrs, :item)
    customizations = fetch(attrs, :customizations, []) |> List.wrap()

    cond do
      is_binary(existing_id) ->
        %{
          existing_order_item_id: existing_id,
          item_id: item_id,
          customizations: normalize_customizations(customizations)
        }

      is_binary(item_id) ->
        %{
          item_id: item_id,
          customizations: normalize_customizations(customizations)
        }

      true ->
        :invalid
    end
  end

  defp normalize_item(_), do: :invalid

  defp normalize_customizations(values) do
    values
    |> List.wrap()
    |> Enum.reject(&is_nil/1)
    |> Enum.map(&normalize_customization/1)
    |> Enum.reject(&is_nil/1)
    |> Enum.reduce({%{}, []}, fn %{key_id: key_id, value_ids: value_ids}, {acc, order} ->
      merged_values =
        Map.get(acc, key_id, [])
        |> Kernel.++(value_ids)
        |> Enum.reject(&is_nil/1)
        |> Enum.uniq()

      updated_acc = Map.put(acc, key_id, merged_values)
      updated_order = if key_id in order, do: order, else: [key_id | order]
      {updated_acc, updated_order}
    end)
    |> case do
      {acc, order} ->
        order
        |> Enum.reverse()
        |> Enum.map(fn key_id -> %{key_id: key_id, value_ids: Map.get(acc, key_id, [])} end)
    end
  end

  defp normalize_customization(%{} = attrs) do
    key_id =
      fetch_id(attrs, :key_id) ||
        fetch_id(attrs, :key) ||
        fetch_id(attrs, :belongs_to)

    raw_values =
      fetch(attrs, :value_ids, [])
      |> List.wrap()
      |> Kernel.++(List.wrap(fetch(attrs, :value)))

    value_ids =
      raw_values
      |> Enum.flat_map(fn
        nil -> []
        entry -> List.wrap(entry)
      end)
      |> Enum.map(&extract_id/1)
      |> Enum.reject(&is_nil/1)

    cond do
      is_binary(key_id) and value_ids != [] -> %{key_id: key_id, value_ids: value_ids}
      true -> nil
    end
  end

  defp normalize_customization(value) when is_binary(value) do
    # Allow simple string payloads to reference keys directly. A missing value
    # list means the entry should be ignored.
    nil
  end

  defp normalize_customization(_), do: nil

  defp fetch(attrs, key), do: fetch(attrs, key, nil)

  defp fetch(attrs, key, default) when is_map(attrs) do
    case Map.fetch(attrs, key) do
      {:ok, value} -> value
      :error -> Map.get(attrs, to_string(key), default)
    end
  end

  defp fetch(_attrs, _key, default), do: default

  defp fetch_id(attrs, key) do
    attrs
    |> fetch(key)
    |> extract_id()
  end

  defp extract_id(value) when is_binary(value), do: value
  defp extract_id(%{id: id}) when is_binary(id), do: id
  defp extract_id(%{"id" => id}) when is_binary(id), do: id
  defp extract_id(%{value: value}) when is_binary(value), do: value
  defp extract_id(%{"value" => value}) when is_binary(value), do: value
  defp extract_id(_), do: nil

  defp maybe_put(map, _key, nil), do: map
  defp maybe_put(map, key, value), do: Map.put(map, key, value)

  defp to_boolean(value) when value in [true, 1, "1", "true", "TRUE"], do: true
  defp to_boolean(value) when value in [false, 0, "0", "false", "FALSE"], do: false

  defp to_boolean(value) when is_binary(value) do
    value
    |> String.trim()
    |> String.downcase()
    |> case do
      "1" -> true
      "true" -> true
      "yes" -> true
      "y" -> true
      "0" -> false
      "false" -> false
      "no" -> false
      "n" -> false
      "" -> false
      _ -> false
    end
  end

  defp to_boolean(_), do: false
end
