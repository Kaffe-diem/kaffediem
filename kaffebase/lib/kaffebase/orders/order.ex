defmodule Kaffebase.Orders.Order do
  use Ecto.Schema
  import Ecto.Changeset

  alias Kaffebase.Ids

  defmodule ItemCustomization do
    use Ecto.Schema
    import Ecto.Changeset

    @primary_key false
    embedded_schema do
      field :key_id, :string
      field :key_name, :string
      field :value_id, :string
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
      field :item_id, :string
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
  @primary_key {:id, :string, autogenerate: false}

  schema "order" do
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
    |> cast(attrs, [:id, :customer_id, :day_id, :missing_information, :state])
    |> cast_embed(:items, with: &ItemSnapshot.changeset/2)
    |> maybe_put_id()
    |> validate_required([:state])
  end

  def states, do: @states

  def to_serializable_items(nil), do: []
  def to_serializable_items(items), do: Enum.map(items, &serialize_item/1)

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

  defp maybe_put_id(changeset) do
    case get_field(changeset, :id) do
      nil -> put_change(changeset, :id, Ids.generate())
      _ -> changeset
    end
  end
end

defimpl Jason.Encoder, for: Kaffebase.Orders.Order do
  def encode(order, opts) do
    Jason.Encode.map(
      %{
        id: order.id,
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
