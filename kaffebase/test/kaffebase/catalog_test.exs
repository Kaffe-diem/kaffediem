defmodule Kaffebase.CatalogTest do
  use Kaffebase.DataCase

  alias Kaffebase.Catalog

  alias Kaffebase.Catalog.{
    Category,
    CustomizationKey,
    CustomizationValue,
    Item,
    ItemCustomization
  }

  alias Kaffebase.CatalogFixtures
  alias Kaffebase.Repo

  setup do
    Repo.delete_all(ItemCustomization)
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

      assert [^earlier, ^later] = Catalog.list_categories()
    end
  end

  describe "items" do
    test "list_items/1 filters by category" do
      category_a = CatalogFixtures.category_fixture()
      category_b = CatalogFixtures.category_fixture()

      item_a = CatalogFixtures.item_fixture(%{category: category_a.id})
      _item_b = CatalogFixtures.item_fixture(%{category: category_b.id})

      result = Catalog.list_items(category_id: category_a.id)
      assert Enum.map(result, & &1.id) == [item_a.id]
    end
  end

  describe "customization values" do
    test "list_customization_values/1 filters by key" do
      key_a = CatalogFixtures.customization_key_fixture()
      key_b = CatalogFixtures.customization_key_fixture()
      value_a = CatalogFixtures.customization_value_fixture(%{key: key_a})
      _value_b = CatalogFixtures.customization_value_fixture(%{key: key_b})

      result = Catalog.list_customization_values(key_id: key_a.id)
      assert Enum.map(result, & &1.id) == [value_a.id]
    end
  end

  describe "item customizations" do
    test "list_item_customizations/1 with preloads populates expand" do
      key = CatalogFixtures.customization_key_fixture()
      value = CatalogFixtures.customization_value_fixture(%{key: key})
      customization = CatalogFixtures.item_customization_fixture(%{key: key, values: [value]})

      [loaded] = Catalog.list_item_customizations(preload: [:key, :values])
      assert loaded.id == customization.id
      assert %CustomizationKey{id: key_id} = loaded.expand.key
      assert key_id == key.id

      assert [%CustomizationValue{id: value_id}] = loaded.expand.value
      assert value_id == value.id
    end

    test "list_item_customizations_by_ids/2 filters and preloads" do
      key = CatalogFixtures.customization_key_fixture()
      value = CatalogFixtures.customization_value_fixture(%{key: key})
      customization = CatalogFixtures.item_customization_fixture(%{key: key, values: [value]})
      _other = CatalogFixtures.item_customization_fixture()

      [loaded] =
        Catalog.list_item_customizations_by_ids([customization.id], preload: [:key, :values])

      assert loaded.id == customization.id
      assert %CustomizationKey{id: key_id} = loaded.expand.key
      assert key_id == key.id

      assert [%CustomizationValue{id: value_id}] = loaded.expand.value
      assert value_id == value.id
    end
  end
end
