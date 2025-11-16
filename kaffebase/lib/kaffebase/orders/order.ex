defmodule Kaffebase.Orders.Order do
  use Ecto.Schema
  import Ecto.Changeset

  defmodule ItemCustomization do
    use Ecto.Schema
    import Ecto.Changeset

    @primary_key false
    embedded_schema do
      field :key_id, :integer
      field :key_name, :string
      field :value_id, :integer
      field :value_name, :string
      field :price_change, :float
      field :label_color, :string, virtual: true
    end

    def changeset(schema, attrs) do
      schema
      |> cast(attrs, [:key_id, :key_name, :value_id, :value_name, :price_change, :label_color])
      |> validate_required([:key_id, :value_id])
    end
  end

  defmodule ItemSnapshot do
    use Ecto.Schema
    import Ecto.Changeset

    alias Kaffebase.Orders.Order.ItemCustomization

    @primary_key false
    embedded_schema do
      field :item_id, :integer
      field :name, :string
      field :price, :float
      field :category, :string
      embeds_many :customizations, ItemCustomization, on_replace: :delete
    end

    def changeset(schema, attrs) do
      schema
      |> cast(attrs, [:item_id, :name, :price, :category])
      |> cast_embed(:customizations, with: &ItemCustomization.changeset/2)
      |> validate_required([:item_id, :name])
    end
  end

  @states [:received, :production, :completed, :dispatched]

  schema "order" do
    field :uuid, :string
    field :customer_id, :integer
    field :day_id, :integer
    embeds_many :items, ItemSnapshot, on_replace: :delete, source: :items_data
    field :missing_information, :boolean

    field :state, Ecto.Enum, values: @states

    timestamps()
  end

  @doc false
  def changeset(order, attrs) do
    order
    |> cast(attrs, [:uuid, :customer_id, :day_id, :missing_information, :state])
    |> cast_embed(:items, with: &ItemSnapshot.changeset/2)
    |> maybe_put_uuid()
    |> validate_required([:state, :uuid])
  end

  def states, do: @states

  def to_serializable_items(nil), do: []
  def to_serializable_items(items), do: Enum.map(items, &serialize_item/1)

  defp maybe_put_uuid(changeset) do
    case get_field(changeset, :uuid) do
      nil -> put_change(changeset, :uuid, Ecto.UUID.generate())
      _ -> changeset
    end
  end

  defp serialize_item(%ItemSnapshot{} = item) do
    %{
      item_id: item.item_id,
      name: item.name,
      price: item.price,
      category: item.category,
      customizations: Enum.map(item.customizations || [], &serialize_customization/1)
    }
  end

  defp serialize_customization(%ItemCustomization{} = customization) do
    %{
      key_id: customization.key_id,
      key_name: customization.key_name,
      value_id: customization.value_id,
      value_name: customization.value_name,
      price_change: customization.price_change,
      label_color: customization.label_color
    }
  end
end

defimpl Jason.Encoder, for: Kaffebase.Orders.Order do
  def encode(order, opts) do
    Jason.Encode.map(
      %{
        id: order.id,
        uuid: order.uuid,
        customer_id: order.customer_id,
        day_id: order.day_id,
        state: order.state,
        missing_information: order.missing_information,
        items: Kaffebase.Orders.Order.to_serializable_items(order.items),
        inserted_at: order.inserted_at,
        updated_at: order.updated_at
      },
      opts
    )
  end
end
