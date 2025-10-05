defmodule KaffebaseWeb.PBSerializer do
  @moduledoc """
  Transforms Ecto structs into PocketBase-compatible JSON maps.
  """

  alias Decimal

  @collection_names %{
    Kaffebase.Accounts.User => "user",
    Kaffebase.Catalog.Category => "category",
    Kaffebase.Catalog.Item => "item",
    Kaffebase.Catalog.CustomizationKey => "customization_key",
    Kaffebase.Catalog.CustomizationValue => "customization_value",
    Kaffebase.Catalog.ItemCustomization => "item_customization",
    Kaffebase.Orders.Order => "order",
    Kaffebase.Orders.OrderItem => "order_item",
    Kaffebase.Content.Message => "message",
    Kaffebase.Content.Status => "status"
  }

  @spec resource(nil | struct() | [struct()] | map()) :: any()
  def resource(nil), do: nil
  def resource(list) when is_list(list), do: Enum.map(list, &resource/1)

  def resource(%{__struct__: struct_module} = struct) do
    if function_exported?(struct_module, :__schema__, 1) do
      record(struct)
    else
      struct
    end
  end

  def resource(%{} = map) do
    map
    |> Enum.map(fn {key, value} -> {key, resource(value)} end)
    |> Enum.into(%{})
  end

  defp record(struct) do
    module = struct.__struct__
    fields = module.__schema__(:fields)

    base =
      Enum.reduce(fields, %{}, fn field, acc ->
        value = Map.get(struct, field)
        encoded = encode_value(value)

        source = module.__schema__(:field_source, field)
        Map.put(acc, source, encoded)
      end)

    collection =
      Map.get(
        @collection_names,
        module,
        module |> Module.split() |> List.last() |> Macro.underscore()
      )

    expand = struct |> Map.get(:expand, %{}) |> encode_expand()

    base
    |> Map.put(:collectionId, collection)
    |> Map.put(:collectionName, collection)
    |> Map.put(:expand, expand)
  end

  defp encode_value(%Decimal{} = decimal), do: Decimal.to_float(decimal)
  defp encode_value(%DateTime{} = datetime), do: DateTime.to_iso8601(datetime)
  defp encode_value(%NaiveDateTime{} = datetime), do: NaiveDateTime.to_iso8601(datetime)
  defp encode_value(%Date{} = date), do: Date.to_iso8601(date)
  defp encode_value(%Time{} = time), do: Time.to_iso8601(time)
  defp encode_value(value) when is_list(value), do: Enum.map(value, &encode_value/1)
  defp encode_value(%Ecto.Association.NotLoaded{}), do: nil
  defp encode_value(%{__struct__: _} = struct), do: resource(struct)
  defp encode_value(value) when is_atom(value), do: Atom.to_string(value)
  defp encode_value(value), do: value

  defp encode_expand(nil), do: %{}

  defp encode_expand(%{} = expand_map) do
    expand_map
    |> Enum.map(fn {key, value} ->
      key = to_string(key)
      value = resource(value)
      {key, value}
    end)
    |> Enum.into(%{})
  end
end
