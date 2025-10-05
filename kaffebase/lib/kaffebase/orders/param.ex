defmodule Kaffebase.Orders.Param do
  @moduledoc """
  Normalization helpers for PocketBase-compatible order payloads.
  """

  @type attrs :: map() | %{optional(atom()) => term()} | %{optional(String.t()) => term()}

  @spec attr(attrs(), atom(), term()) :: term()
  def attr(attrs, key, default \\ nil) do
    keys_for(key)
    |> Enum.find_value(fn candidate -> value_for(attrs, candidate) end)
    |> case do
      nil -> default
      value -> value
    end
  end

  @spec extract_record_id(term()) :: String.t() | nil
  def extract_record_id(value) when is_binary(value), do: value

  def extract_record_id(%{id: id}) when is_binary(id), do: id
  def extract_record_id(%{"id" => id}) when is_binary(id), do: id
  def extract_record_id(_), do: nil

  @spec extract_value_id(term()) :: String.t() | nil
  def extract_value_id(%{value: value}) when is_binary(value), do: value
  def extract_value_id(%{"value" => value}) when is_binary(value), do: value
  def extract_value_id(%{id: id}) when is_binary(id), do: id
  def extract_value_id(%{"id" => id}) when is_binary(id), do: id
  def extract_value_id(value) when is_binary(value), do: value
  def extract_value_id(_), do: nil

  @spec normalize_id_list(term()) :: [String.t()]
  def normalize_id_list(value) do
    value
    |> List.wrap()
    |> Enum.map(&extract_record_id/1)
    |> Enum.reject(&is_nil/1)
  end

  @spec normalize_customizations(term()) :: [map()]
  def normalize_customizations(customizations) do
    normalized =
      customizations
      |> List.wrap()
      |> Enum.reject(&is_nil/1)

    cond do
      normalized == [] ->
        []

      Enum.all?(normalized, &group_shape?/1) ->
        normalized
        |> Enum.map(&normalize_group_customization/1)
        |> Enum.reject(&(is_nil(&1.key) || Enum.empty?(&1.value)))

      true ->
        normalized
        |> Enum.group_by(&extract_record_id(attr(&1, :key)))
        |> Enum.reject(fn {key, _} -> is_nil(key) end)
        |> Enum.map(fn {key, values} ->
          %{
            key: key,
            value:
              values
              |> Enum.map(&extract_value_id/1)
              |> Enum.reject(&is_nil/1)
          }
        end)
    end
  end

  @spec cast_state(term()) :: atom()
  def cast_state(nil), do: :received
  def cast_state(""), do: :received

  def cast_state(state) when is_atom(state) do
    case state do
      s when s in [:received, :production, :completed, :dispatched] -> s
      _ -> :received
    end
  end

  def cast_state(state) when is_binary(state) do
    case String.downcase(state) do
      "received" -> :received
      "production" -> :production
      "completed" -> :completed
      "dispatched" -> :dispatched
      _ -> :received
    end
  end

  def cast_state(_), do: :received

  # --------------------------------------------------------------------------
  # Internal helpers

  defp value_for(nil, _candidate), do: nil
  defp value_for(attrs, candidate) when is_atom(candidate), do: Map.get(attrs, candidate)
  defp value_for(attrs, candidate) when is_binary(candidate), do: Map.get(attrs, candidate)

  defp keys_for(:customer), do: [:customer, "customer", :customer_id, "customer_id"]
  defp keys_for(:day_id), do: [:day_id, "day_id"]
  defp keys_for(:missing_information), do: [:missing_information, "missing_information"]
  defp keys_for(:state), do: [:state, "state"]
  defp keys_for(:items), do: [:items, "items", :item_ids, "item_ids"]
  defp keys_for(:item), do: [:item, "item", :item_id, "item_id"]

  defp keys_for(:order_item),
    do: [:order_item, "order_item", :order_item_id, "order_item_id", :id, "id"]

  defp keys_for(:customizations),
    do: [:customization, "customization", :customizations, "customizations"]

  defp keys_for(:key), do: [:key, "key", :belongs_to, "belongs_to", :key_id, "key_id"]
  defp keys_for(:value), do: [:value, "value", :value_ids, "value_ids"]
  defp keys_for(key), do: [key, to_string(key)]

  defp normalize_group_customization(customization) do
    %{
      key: attr(customization, :key) |> extract_record_id(),
      value:
        customization
        |> attr(:value, [])
        |> List.wrap()
        |> Enum.map(&extract_value_id/1)
        |> Enum.reject(&is_nil/1)
    }
  end

  defp group_shape?(customization) do
    !is_nil(attr(customization, :value))
  end
end
