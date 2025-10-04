defmodule Kaffebase.Catalog do
  @moduledoc """
  Catalog context that replaces the PocketBase collections for menu configuration.
  """

  import Ecto.Query, warn: false

  alias Kaffebase.Repo

  alias Kaffebase.Catalog.{
    Category,
    CustomizationKey,
    CustomizationValue,
    Item,
    ItemCustomization
  }

  @type order_option :: {:asc | :desc, atom()}

  # Category -----------------------------------------------------------------

  @spec list_categories(keyword()) :: [Category.t()]
  def list_categories(opts \\ []) do
    Category
    |> maybe_apply_order(opts[:order_by] || [asc: :sort_order, asc: :name])
    |> Repo.all()
  end

  @spec get_category!(String.t()) :: Category.t()
  def get_category!(id), do: Repo.get!(Category, id)

  @spec create_category(map()) :: {:ok, Category.t()} | {:error, Ecto.Changeset.t()}
  def create_category(attrs \\ %{}) do
    %Category{}
    |> Category.changeset(attrs)
    |> Repo.insert()
  end

  @spec update_category(Category.t(), map()) :: {:ok, Category.t()} | {:error, Ecto.Changeset.t()}
  def update_category(%Category{} = category, attrs) do
    category
    |> Category.changeset(attrs)
    |> Repo.update()
  end

  @spec delete_category(Category.t()) :: {:ok, Category.t()} | {:error, Ecto.Changeset.t()}
  def delete_category(%Category{} = category), do: Repo.delete(category)

  @spec change_category(Category.t(), map()) :: Ecto.Changeset.t()
  def change_category(%Category{} = category, attrs \\ %{}),
    do: Category.changeset(category, attrs)

  # Item ----------------------------------------------------------------------

  @spec list_items(keyword()) :: [Item.t()]
  def list_items(opts \\ []) do
    Item
    |> maybe_filter(:category, opts[:category] || opts[:category_id])
    |> maybe_apply_order(opts[:order_by] || [asc: :sort_order, asc: :name])
    |> Repo.all()
  end

  @spec get_item!(String.t()) :: Item.t()
  def get_item!(id), do: Repo.get!(Item, id)

  @spec create_item(map()) :: {:ok, Item.t()} | {:error, Ecto.Changeset.t()}
  def create_item(attrs \\ %{}) do
    %Item{}
    |> Item.changeset(attrs)
    |> Repo.insert()
  end

  @spec update_item(Item.t(), map()) :: {:ok, Item.t()} | {:error, Ecto.Changeset.t()}
  def update_item(%Item{} = item, attrs) do
    item
    |> Item.changeset(attrs)
    |> Repo.update()
  end

  @spec delete_item(Item.t()) :: {:ok, Item.t()} | {:error, Ecto.Changeset.t()}
  def delete_item(%Item{} = item), do: Repo.delete(item)

  @spec change_item(Item.t(), map()) :: Ecto.Changeset.t()
  def change_item(%Item{} = item, attrs \\ %{}), do: Item.changeset(item, attrs)

  # Customization keys --------------------------------------------------------

  @spec list_customization_keys(keyword()) :: [CustomizationKey.t()]
  def list_customization_keys(opts \\ []) do
    CustomizationKey
    |> maybe_apply_order(opts[:order_by] || [asc: :sort_order, asc: :name])
    |> Repo.all()
  end

  @spec get_customization_key!(String.t()) :: CustomizationKey.t()
  def get_customization_key!(id), do: Repo.get!(CustomizationKey, id)

  @spec create_customization_key(map()) ::
          {:ok, CustomizationKey.t()} | {:error, Ecto.Changeset.t()}
  def create_customization_key(attrs \\ %{}) do
    %CustomizationKey{}
    |> CustomizationKey.changeset(attrs)
    |> Repo.insert()
  end

  @spec update_customization_key(CustomizationKey.t(), map()) ::
          {:ok, CustomizationKey.t()} | {:error, Ecto.Changeset.t()}
  def update_customization_key(%CustomizationKey{} = key, attrs) do
    key
    |> CustomizationKey.changeset(attrs)
    |> Repo.update()
  end

  @spec delete_customization_key(CustomizationKey.t()) ::
          {:ok, CustomizationKey.t()} | {:error, Ecto.Changeset.t()}
  def delete_customization_key(%CustomizationKey{} = key), do: Repo.delete(key)

  @spec change_customization_key(CustomizationKey.t(), map()) :: Ecto.Changeset.t()
  def change_customization_key(%CustomizationKey{} = key, attrs \\ %{}),
    do: CustomizationKey.changeset(key, attrs)

  # Customization values ------------------------------------------------------

  @spec list_customization_values(keyword()) :: [CustomizationValue.t()]
  def list_customization_values(opts \\ []) do
    CustomizationValue
    |> maybe_filter(:belongs_to, opts[:belongs_to] || opts[:key_id])
    |> maybe_apply_order(opts[:order_by] || [asc: :sort_order, asc: :name])
    |> Repo.all()
  end

  @spec get_customization_value!(String.t()) :: CustomizationValue.t()
  def get_customization_value!(id), do: Repo.get!(CustomizationValue, id)

  @spec create_customization_value(map()) ::
          {:ok, CustomizationValue.t()} | {:error, Ecto.Changeset.t()}
  def create_customization_value(attrs \\ %{}) do
    %CustomizationValue{}
    |> CustomizationValue.changeset(attrs)
    |> Repo.insert()
  end

  @spec update_customization_value(CustomizationValue.t(), map()) ::
          {:ok, CustomizationValue.t()} | {:error, Ecto.Changeset.t()}
  def update_customization_value(%CustomizationValue{} = value, attrs) do
    value
    |> CustomizationValue.changeset(attrs)
    |> Repo.update()
  end

  @spec delete_customization_value(CustomizationValue.t()) ::
          {:ok, CustomizationValue.t()} | {:error, Ecto.Changeset.t()}
  def delete_customization_value(%CustomizationValue{} = value), do: Repo.delete(value)

  @spec change_customization_value(CustomizationValue.t(), map()) :: Ecto.Changeset.t()
  def change_customization_value(%CustomizationValue{} = value, attrs \\ %{}),
    do: CustomizationValue.changeset(value, attrs)

  # Item customizations -------------------------------------------------------

  @spec list_item_customizations(keyword()) :: [ItemCustomization.t()]
  def list_item_customizations(opts \\ []) do
    ItemCustomization
    |> Repo.all()
    |> maybe_attach(:key, opts)
    |> maybe_attach(:values, opts)
  end

  @spec list_item_customizations_by_ids([String.t()], keyword()) :: [ItemCustomization.t()]
  def list_item_customizations_by_ids(ids, opts \\ []) when is_list(ids) do
    ItemCustomization
    |> where([ic], ic.id in ^ids)
    |> Repo.all()
    |> maybe_attach(:key, opts)
    |> maybe_attach(:values, opts)
  end

  @spec get_item_customization!(String.t(), keyword()) :: ItemCustomization.t()
  def get_item_customization!(id, opts \\ []) do
    ItemCustomization
    |> Repo.get!(id)
    |> maybe_attach_single(:key, opts)
    |> maybe_attach_single(:values, opts)
  end

  @spec create_item_customization(map()) ::
          {:ok, ItemCustomization.t()} | {:error, Ecto.Changeset.t()}
  def create_item_customization(attrs \\ %{}) do
    %ItemCustomization{}
    |> ItemCustomization.changeset(attrs)
    |> Repo.insert()
  end

  @spec update_item_customization(ItemCustomization.t(), map()) ::
          {:ok, ItemCustomization.t()} | {:error, Ecto.Changeset.t()}
  def update_item_customization(%ItemCustomization{} = customization, attrs) do
    customization
    |> ItemCustomization.changeset(attrs)
    |> Repo.update()
  end

  @spec delete_item_customization(ItemCustomization.t()) ::
          {:ok, ItemCustomization.t()} | {:error, Ecto.Changeset.t()}
  def delete_item_customization(%ItemCustomization{} = customization),
    do: Repo.delete(customization)

  @spec change_item_customization(ItemCustomization.t(), map()) :: Ecto.Changeset.t()
  def change_item_customization(%ItemCustomization{} = customization, attrs \\ %{}),
    do: ItemCustomization.changeset(customization, attrs)

  # Helpers ------------------------------------------------------------------

  defp maybe_filter(query, _field, nil), do: query

  defp maybe_filter(query, field, value) do
    where(query, [..., q], field(q, ^field) == ^value)
  end

  defp maybe_apply_order(query, nil), do: query
  defp maybe_apply_order(query, []), do: query

  defp maybe_apply_order(query, orderings) when is_list(orderings) do
    order_by(query, ^orderings)
  end

  defp maybe_attach(records, _what, _opts) when records == [], do: records

  defp maybe_attach(records, what, opts) do
    if preload?(opts, what) do
      do_attach(records, what)
    else
      records
    end
  end

  defp maybe_attach_single(record, what, opts) do
    if preload?(opts, what) do
      hd(do_attach([record], what))
    else
      record
    end
  end

  defp preload?(opts, what) do
    preloads = Keyword.get(opts, :preload, []) |> List.wrap()
    Enum.member?(preloads, what)
  end

  defp do_attach(records, :key) do
    key_map = fetch_map(CustomizationKey, Enum.map(records, & &1.key))

    Enum.map(records, fn record ->
      expand = Map.get(record, :expand, %{}) |> Map.put(:key, Map.get(key_map, record.key))
      Map.put(record, :expand, expand)
    end)
  end

  defp do_attach(records, :values) do
    value_ids = records |> Enum.flat_map(& &1.value) |> Enum.uniq()
    value_map = fetch_map(CustomizationValue, value_ids)

    Enum.map(records, fn record ->
      values = Enum.map(record.value || [], &Map.get(value_map, &1)) |> Enum.reject(&is_nil/1)
      expand = Map.get(record, :expand, %{}) |> Map.put(:value, values)
      Map.put(record, :expand, expand)
    end)
  end

  defp fetch_map(_module, []), do: %{}

  defp fetch_map(module, ids) do
    module
    |> where([m], m.id in ^ids)
    |> Repo.all()
    |> Map.new(&{&1.id, &1})
  end
end
