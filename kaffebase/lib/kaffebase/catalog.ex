defmodule Kaffebase.Catalog do
  @moduledoc """
  Catalog context that replaces the PocketBase collections for menu configuration.
  """

  import Ecto.Query, only: [where: 3]

  alias Kaffebase.Catalog.{
    Category,
    CustomizationKey,
    CustomizationValue,
    Item,
    ItemCustomization,
    Crud
  }

  alias Kaffebase.Repo

  @default_order [asc: :sort_order, asc: :name]
  @category_collection "category"
  @item_collection "item"
  @customization_key_collection "customization_key"
  @customization_value_collection "customization_value"
  @item_customization_collection "item_customization"

  # Category -----------------------------------------------------------------

  def list_categories(opts \\ []), do: Crud.list(Category, opts, @default_order)
  def get_category!(id), do: Crud.get!(Category, id)
  def create_category(attrs \\ %{}), do: Crud.create(Category, attrs, @category_collection)

  def update_category(%Category{} = category, attrs),
    do: Crud.update(Category, category, attrs, @category_collection)

  def delete_category(%Category{} = category),
    do: Crud.delete(Category, category, @category_collection)

  def change_category(%Category{} = category, attrs \\ %{}),
    do: Crud.change(Category, category, attrs)

  # Item ----------------------------------------------------------------------

  def list_items(opts \\ []),
    do: Crud.list(Item, normalize_category_filter(opts), @default_order)

  def get_item(id), do: Crud.get(Item, id)
  def get_item!(id), do: Crud.get!(Item, id)
  def create_item(attrs \\ %{}), do: Crud.create(Item, attrs, @item_collection)

  def update_item(%Item{} = item, attrs),
    do: Crud.update(Item, item, attrs, @item_collection)

  def delete_item(%Item{} = item),
    do: Crud.delete(Item, item, @item_collection)

  def change_item(%Item{} = item, attrs \\ %{}),
    do: Crud.change(Item, item, attrs)

  # Customization keys --------------------------------------------------------

  def list_customization_keys(opts \\ []),
    do: Crud.list(CustomizationKey, opts, @default_order)

  def get_customization_key(id), do: Crud.get(CustomizationKey, id)
  def get_customization_key!(id), do: Crud.get!(CustomizationKey, id)

  def create_customization_key(attrs \\ %{}),
    do: Crud.create(CustomizationKey, attrs, @customization_key_collection)

  def update_customization_key(%CustomizationKey{} = key, attrs),
    do: Crud.update(CustomizationKey, key, attrs, @customization_key_collection)

  def delete_customization_key(%CustomizationKey{} = key),
    do: Crud.delete(CustomizationKey, key, @customization_key_collection)

  def change_customization_key(%CustomizationKey{} = key, attrs \\ %{}),
    do: Crud.change(CustomizationKey, key, attrs)

  # Customization values ------------------------------------------------------

  def list_customization_values(opts \\ []),
    do: Crud.list(CustomizationValue, normalize_customization_value_filter(opts), @default_order)

  def get_customization_value(id), do: Crud.get(CustomizationValue, id)
  def get_customization_value!(id), do: Crud.get!(CustomizationValue, id)

  def create_customization_value(attrs \\ %{}),
    do: Crud.create(CustomizationValue, attrs, @customization_value_collection)

  def update_customization_value(%CustomizationValue{} = value, attrs),
    do: Crud.update(CustomizationValue, value, attrs, @customization_value_collection)

  def delete_customization_value(%CustomizationValue{} = value),
    do: Crud.delete(CustomizationValue, value, @customization_value_collection)

  def change_customization_value(%CustomizationValue{} = value, attrs \\ %{}),
    do: Crud.change(CustomizationValue, value, attrs)

  # Item customizations -------------------------------------------------------

  def list_item_customizations,
    do: Crud.list(ItemCustomization, [order_by: []], [])

  def list_item_customizations_by_ids(ids) when is_list(ids) do
    ItemCustomization
    |> where([ic], ic.id in ^ids)
    |> Repo.all()
  end

  def get_item_customization!(id), do: Crud.get!(ItemCustomization, id)

  def create_item_customization(attrs \\ %{}),
    do: Crud.create(ItemCustomization, attrs, @item_customization_collection)

  def update_item_customization(%ItemCustomization{} = customization, attrs),
    do: Crud.update(ItemCustomization, customization, attrs, @item_customization_collection)

  def delete_item_customization(%ItemCustomization{} = customization),
    do: Crud.delete(ItemCustomization, customization, @item_customization_collection)

  def change_item_customization(%ItemCustomization{} = customization, attrs \\ %{}),
    do: Crud.change(ItemCustomization, customization, attrs)

  # Helpers ------------------------------------------------------------------

  defp normalize_category_filter(opts) do
    category = opts[:category] || opts[:category_id]

    opts
    |> Keyword.drop([:category, :category_id])
    |> put_filter(:category, category)
  end

  defp normalize_customization_value_filter(opts) do
    belongs_to = opts[:belongs_to] || opts[:key_id]

    opts
    |> Keyword.drop([:belongs_to, :key_id])
    |> put_filter(:belongs_to, belongs_to)
  end

  defp put_filter(opts, _field, nil), do: opts

  defp put_filter(opts, field, value) do
    Keyword.update(opts, :filter, {field, value}, fn
      {_, _} = existing -> [existing, {field, value}]
      list when is_list(list) -> [{field, value} | list]
      other -> [other, {field, value}]
    end)
  end
end
