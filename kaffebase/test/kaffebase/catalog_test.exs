defmodule Kaffebase.CatalogTest do
  use Kaffebase.DataCase

  alias Kaffebase.Catalog.{
    Category,
    CustomizationKey,
    CustomizationValue,
    Item,
    Crud
  }

  alias Kaffebase.CatalogFixtures
  alias Kaffebase.Repo

  setup do
    Repo.delete_all(CustomizationValue)
    Repo.delete_all(CustomizationKey)
    Repo.delete_all(Item)
    Repo.delete_all(Category)
    :ok
  end

  describe "categories" do
    test "list_categories/1 sorts by sort_order and name" do
      later = CatalogFixtures.category_fixture(%{name: "B", sort_order: 2})
      earlier = CatalogFixtures.category_fixture(%{name: "A", sort_order: 1})

      assert [^earlier, ^later] = Crud.list(Category)
    end
  end

  describe "items" do
    test "list_items/0 returns all items" do
      category_a = CatalogFixtures.category_fixture()
      category_b = CatalogFixtures.category_fixture()

      item_a = CatalogFixtures.item_fixture(%{category: category_a})
      item_b = CatalogFixtures.item_fixture(%{category: category_b})

      result = Crud.list(Item)
      assert length(result) == 2
      assert Enum.map(result, & &1.id) |> Enum.sort() == [item_a.id, item_b.id] |> Enum.sort()
    end
  end

  describe "customization values" do
    test "list_customization_values/0 returns all values" do
      key_a = CatalogFixtures.customization_key_fixture()
      key_b = CatalogFixtures.customization_key_fixture()
      value_a = CatalogFixtures.customization_value_fixture(%{key: key_a})
      value_b = CatalogFixtures.customization_value_fixture(%{key: key_b})

      result = Crud.list(CustomizationValue)
      assert length(result) == 2
      assert Enum.map(result, & &1.id) |> Enum.sort() == [value_a.id, value_b.id] |> Enum.sort()
    end
  end
end
