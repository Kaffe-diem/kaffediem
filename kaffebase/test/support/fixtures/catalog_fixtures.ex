defmodule Kaffebase.CatalogFixtures do
  @moduledoc false

  alias Kaffebase.Catalog

  def unique_string(prefix) do
    unique = System.unique_integer([:positive, :monotonic])
    "#{prefix}_#{unique}"
  end

  def category_fixture(attrs \\ %{}) do
    defaults = %{
      name: unique_string("Category"),
      enable: true,
      sort_order: 1,
      valid_customizations: []
    }

    {:ok, category} =
      attrs
      |> Enum.into(defaults)
      |> Catalog.create_category()

    category
  end

  def item_fixture(attrs \\ %{}) do
    category_ref = Map.get_lazy(attrs, :category, fn -> category_fixture() end)
    category_id = id_of(category_ref)

    defaults = %{
      name: unique_string("Item"),
      category: category_id,
      price_nok: Decimal.new("100"),
      enable: true,
      sort_order: 1,
      image: ""
    }

    {:ok, item} =
      attrs
      |> Map.delete(:category)
      |> Enum.into(defaults)
      |> Catalog.create_item()

    item
  end

  def customization_key_fixture(attrs \\ %{}) do
    defaults = %{
      name: unique_string("Key"),
      enable: true,
      label_color: "#000000",
      multiple_choice: false,
      sort_order: 1,
      default_value: nil
    }

    {:ok, key} =
      attrs
      |> Enum.into(defaults)
      |> Catalog.create_customization_key()

    key
  end

  def customization_value_fixture(attrs \\ %{}) do
    key_ref = Map.get_lazy(attrs, :key, fn -> customization_key_fixture() end)
    key_id = id_of(key_ref)

    defaults = %{
      name: unique_string("Value"),
      belongs_to: key_id,
      price_increment_nok: Decimal.new("10"),
      constant_price: false,
      enable: true,
      sort_order: 1
    }

    {:ok, value} =
      attrs
      |> Map.delete(:key)
      |> Enum.into(defaults)
      |> Catalog.create_customization_value()

    value
  end

  def item_customization_fixture(attrs \\ %{}) do
    key_ref = Map.get_lazy(attrs, :key, fn -> customization_key_fixture() end)
    key_id = id_of(key_ref)

    values_ref =
      Map.get_lazy(attrs, :values, fn -> [customization_value_fixture(%{key: key_id})] end)

    value_ids =
      values_ref
      |> List.wrap()
      |> Enum.map(&id_of/1)

    defaults = %{
      key: key_id,
      value: value_ids
    }

    {:ok, item_customization} =
      attrs
      |> Map.drop([:key, :values])
      |> Enum.into(defaults)
      |> Catalog.create_item_customization()

    item_customization
  end

  defp id_of(%{id: id}) when is_binary(id), do: id
  defp id_of(%{"id" => id}) when is_binary(id), do: id
  defp id_of(id) when is_binary(id), do: id
end
