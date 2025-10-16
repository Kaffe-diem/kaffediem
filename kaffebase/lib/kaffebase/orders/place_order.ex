defmodule Kaffebase.Orders.PlaceOrder do
  @moduledoc """
  Command to place an order - builds denormalized snapshots from catalog.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Kaffebase.Catalog
  alias Kaffebase.Orders.Order

  @states Order.states()

  defmodule ItemCustomization do
    @moduledoc false
    use Ecto.Schema

    @primary_key false
    embedded_schema do
      field :key, :string
      field :value, {:array, :string}
    end
  end

  defmodule Item do
    @moduledoc false
    use Ecto.Schema
    import Ecto.Changeset

    @primary_key false
    embedded_schema do
      field :item, :string
      field :catalog_item, :map, virtual: true
      embeds_many :customizations, ItemCustomization
    end

    def changeset(schema, attrs) do
      schema
      |> cast(attrs, [:item])
      |> cast_embed(:customizations, with: &customization_changeset/2)
      |> validate_required([:item])
    end

    defp customization_changeset(schema, attrs) do
      schema
      |> cast(attrs, [:key, :value])
      |> validate_required([:key, :value])
    end
  end

  @primary_key false

  embedded_schema do
    field :customer_id, :integer
    field :missing_information, :boolean, default: false
    field :state, Ecto.Enum, values: @states, default: :received
    embeds_many :items, Item
  end

  @type t :: %__MODULE__{
          customer_id: integer() | nil,
          missing_information: boolean(),
          state: Order.state(),
          items: [Item.t()]
        }

  @spec new(map()) :: {:ok, t()} | {:error, Ecto.Changeset.t()}
  def new(attrs) when is_map(attrs) do
    changeset = changeset(%__MODULE__{}, attrs)

    with {:ok, _command} <- apply_action(changeset, :insert),
         {:ok, snapshots} <- build_snapshots_from_changeset(changeset) do
      command = Ecto.Changeset.apply_changes(changeset)
      {:ok, %{command | items: snapshots}}
    end
  end

  defp changeset(schema, attrs) do
    schema
    |> cast(attrs, [:customer_id, :missing_information, :state])
    |> cast_embed(:items, with: &item_changeset/2, required: true)
    |> validate_length(:items, min: 1)
  end

  defp item_changeset(schema, attrs) do
    changeset = Item.changeset(schema, attrs)

    case get_field(changeset, :item) do
      nil ->
        add_error(changeset, :item, "is required")

      item_id ->
        case Catalog.get_item(item_id) do
          nil ->
            add_error(changeset, :item, "not found")

          catalog_item ->
            # Store resolved catalog item for snapshot building
            put_change(changeset, :catalog_item, catalog_item)
        end
    end
  end

  defp build_snapshots_from_changeset(changeset) do
    items =
      changeset
      |> get_field(:items)
      |> Enum.map(&build_item_snapshot/1)

    {:ok, items}
  end

  defp build_item_snapshot(%Item{catalog_item: %{} = catalog_item} = item_input) do
    snapshot_item(catalog_item, item_input.customizations)
  end

  defp snapshot_item(catalog_item, customization_inputs) do
    %{
      item_id: catalog_item.id,
      name: catalog_item.name,
      price: Decimal.to_string(catalog_item.price_nok),
      category: catalog_item.category,
      customizations: build_customizations_snapshot(customization_inputs)
    }
  end

  defp build_customizations_snapshot(customization_inputs) when is_list(customization_inputs) do
    Enum.flat_map(customization_inputs, &snapshot_customization/1)
  end

  defp build_customizations_snapshot(_), do: []

  defp snapshot_customization(%ItemCustomization{key: key_id, value: value_ids}) do
    with %{} = key <- Catalog.get_customization_key(key_id) do
      for value_id <- value_ids,
          value = Catalog.get_customization_value(value_id),
          not is_nil(value) do
        snapshot_customization_value(key, value)
      end
    else
      _ -> []
    end
  end

  defp snapshot_customization_value(key, value) do
    %{
      key_id: key.id,
      key_name: key.name,
      value_id: value.id,
      value_name: value.name,
      price_change: Decimal.to_string(value.price_increment_nok || 0)
    }
  end
end
