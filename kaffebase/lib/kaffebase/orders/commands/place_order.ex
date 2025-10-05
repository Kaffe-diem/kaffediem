defmodule Kaffebase.Orders.Commands.PlaceOrder do
  @moduledoc """
  Command schema that normalizes incoming order payloads before persistence.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__.Customization
  alias __MODULE__.Item
  alias Kaffebase.Orders.Order
  alias Kaffebase.Orders.Param

  @primary_key false

  embedded_schema do
    field(:customer_id, :string)
    field(:missing_information, :boolean, default: false)
    field(:state, Ecto.Enum, values: Order.states())

    embeds_many(:items, Item, on_replace: :delete)
  end

  @type t :: %__MODULE__{
          customer_id: String.t() | nil,
          missing_information: boolean(),
          state: Order.state(),
          items: [Item.t()]
        }

  @spec new(map()) :: {:ok, t()} | {:error, Ecto.Changeset.t()}
  def new(attrs) when is_map(attrs) do
    %__MODULE__{}
    |> changeset(attrs)
    |> apply_action(:insert)
  end

  defp changeset(schema, attrs) do
    sanitized = sanitize(attrs)

    schema
    |> cast(sanitized, [:customer_id, :missing_information, :state])
    |> validate_required([:state])
    |> cast_embed(:items, required: true)
    |> validate_length(:items, min: 1)
  end

  defp sanitize(attrs) do
    %{
      customer_id: Param.extract_record_id(Param.attr(attrs, :customer)),
      missing_information: to_boolean(Param.attr(attrs, :missing_information, false)),
      state: Param.cast_state(Param.attr(attrs, :state)),
      items: sanitize_items(Param.attr(attrs, :items, []))
    }
  end

  defp sanitize_items(items) do
    items
    |> List.wrap()
    |> Enum.reject(&is_nil/1)
    |> Enum.map(&sanitize_item/1)
  end

  defp sanitize_item(item) when is_binary(item) do
    %{existing_order_item_id: item, customizations: []}
  end

  defp sanitize_item(%{} = attrs) do
    %{
      existing_order_item_id:
        attrs
        |> Param.attr(:order_item)
        |> Param.extract_record_id(),
      item_id:
        attrs
        |> Param.attr(:item)
        |> Param.extract_record_id(),
      customizations:
        attrs
        |> Param.attr(:customizations, [])
        |> Param.normalize_customizations()
        |> Enum.map(&Customization.from_map/1)
    }
  end

  defp sanitize_item(_), do: %{}

  defp to_boolean(value) when value in [true, 1, "1", "true", "TRUE"], do: true
  defp to_boolean(value) when value in [false, 0, "0", "false", "FALSE", nil], do: false
  defp to_boolean(_), do: false

  # --------------------------------------------------------------------------
  # Nested schemas

  defmodule Item do
    @moduledoc false
    use Ecto.Schema
    import Ecto.Changeset

    alias Kaffebase.Orders.Commands.PlaceOrder.Customization

    @primary_key false

    embedded_schema do
      field(:existing_order_item_id, :string)
      field(:item_id, :string)

      embeds_many(:customizations, Customization, on_replace: :delete)
    end

    @type t :: %__MODULE__{
            existing_order_item_id: String.t() | nil,
            item_id: String.t() | nil,
            customizations: [Customization.t()]
          }

    def changeset(schema, attrs) do
      schema
      |> cast(attrs, [:existing_order_item_id, :item_id])
      |> cast_embed(:customizations, with: &Customization.changeset/2)
      |> validate_reference()
      |> forbid_customizations_for_existing()
    end

    def existing?(%__MODULE__{existing_order_item_id: id}) when is_binary(id) and id != "",
      do: true

    def existing?(_), do: false

    def new?(%__MODULE__{item_id: id}) when is_binary(id) and id != "", do: true
    def new?(_), do: false

    defp validate_reference(changeset) do
      item_id = get_field(changeset, :item_id)
      existing_id = get_field(changeset, :existing_order_item_id)

      cond do
        is_binary(item_id) and item_id != "" and is_binary(existing_id) and existing_id != "" ->
          changeset
          |> add_error(:item_id, "cannot reference existing order item and provide a new item")

        is_binary(item_id) and item_id != "" ->
          changeset
          |> validate_required([:item_id])

        is_binary(existing_id) and existing_id != "" ->
          changeset

        true ->
          changeset
          |> add_error(:item_id, "is required")
      end
    end

    defp forbid_customizations_for_existing(changeset) do
      existing_id = get_field(changeset, :existing_order_item_id)
      customizations = get_field(changeset, :customizations, [])

      if is_binary(existing_id) and existing_id != "" and customizations != [] do
        add_error(
          changeset,
          :customizations,
          "cannot supply customizations for existing order items"
        )
      else
        changeset
      end
    end
  end

  defmodule Customization do
    @moduledoc false
    use Ecto.Schema
    import Ecto.Changeset

    @primary_key false

    embedded_schema do
      field(:key_id, :string)
      field(:value_ids, {:array, :string}, default: [])
    end

    @type t :: %__MODULE__{key_id: String.t(), value_ids: [String.t()]}

    def changeset(schema, attrs) do
      schema
      |> cast(attrs, [:key_id, :value_ids])
      |> update_change(:value_ids, &normalize_values/1)
      |> validate_required([:key_id])
      |> validate_length(:value_ids, min: 1)
    end

    def from_map(%{key: key, value: value}) do
      %{
        key_id: key,
        value_ids: Enum.map(List.wrap(value), &to_string/1)
      }
    end

    def from_map(_), do: %{}

    defp normalize_values(value) do
      value
      |> List.wrap()
      |> Enum.map(fn
        nil -> nil
        v when is_binary(v) -> v
        v -> to_string(v)
      end)
      |> Enum.reject(&(&1 in [nil, ""]))
      |> Enum.uniq()
    end
  end
end
