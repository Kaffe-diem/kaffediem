defmodule Kaffebase.CatalogFixtures do
  @moduledoc false

  alias Kaffebase.Catalog.{
    Category,
    Crud,
    CustomizationKey,
    CustomizationValue,
    Item
  }

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

    params = Enum.into(attrs, defaults)

    {:ok, category} = Crud.create(Category, params)

    category
  end

  def item_fixture(attrs \\ %{}) do
    category_ref = Map.get_lazy(attrs, :category, fn -> category_fixture() end)
    category_id = id_of(category_ref)

    defaults = %{
      name: unique_string("Item"),
      category_id: category_id,
      price_nok: 100,
      enable: true,
      sort_order: 1,
      image: ""
    }

    params =
      attrs
      |> Map.delete(:category)
      |> Enum.into(defaults)

    {:ok, item} = Crud.create(Item, params)

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

    params = Enum.into(attrs, defaults)

    {:ok, key} = Crud.create(CustomizationKey, params)

    key
  end

  def customization_value_fixture(attrs \\ %{}) do
    key_ref = Map.get_lazy(attrs, :key, fn -> customization_key_fixture() end)
    key_id = id_of(key_ref)

    defaults = %{
      name: unique_string("Value"),
      belongs_to: key_id,
      price_increment_nok: 10,
      constant_price: false,
      enable: true,
      sort_order: 1
    }

    params =
      attrs
      |> Map.delete(:key)
      |> Enum.into(defaults)

    {:ok, value} = Crud.create(CustomizationValue, params)

    value
  end

  defp id_of(%{id: id}) when is_integer(id), do: id
  defp id_of(%{"id" => id}) when is_integer(id), do: id
  defp id_of(id) when is_integer(id), do: id
end
