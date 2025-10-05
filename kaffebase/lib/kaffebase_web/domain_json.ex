defmodule KaffebaseWeb.DomainJSON do
  @moduledoc """
  Serializes Kaffebase domain structs into explicit JSON-ready maps.

  This replaces the dynamic PocketBase serializer with hand written
  transformations so the API surface is tailored to our needs.
  """

  alias Decimal
  alias Kaffebase.Accounts.User

  alias Kaffebase.Catalog.{
    Category,
    CustomizationKey,
    CustomizationValue,
    Item,
    ItemCustomization
  }

  alias Kaffebase.Content.{Message, Status}
  alias Kaffebase.Orders.{Order, OrderItem}

  @type json :: map() | list()

  @spec render(nil | struct() | [struct()] | map()) :: json | nil
  def render(nil), do: nil

  def render(list) when is_list(list) do
    Enum.map(list, &render/1)
  end

  def render(%Order{} = order), do: order(order)
  def render(%OrderItem{} = order_item), do: order_item(order_item)

  def render(%ItemCustomization{} = customization), do: item_customization(customization)
  def render(%CustomizationKey{} = key), do: customization_key(key)
  def render(%CustomizationValue{} = value), do: customization_value(value)

  def render(%Item{} = item), do: item(item)
  def render(%Category{} = category), do: category(category)

  def render(%Message{} = message), do: message(message)
  def render(%Status{} = status), do: status(status)

  def render(%User{} = user), do: user(user)

  def render(%{} = map) do
    map
    |> Enum.map(fn {key, value} -> {key, transform_value(value)} end)
    |> Enum.into(%{})
  end

  def render(value), do: value

  # --------------------------------------------------------------------------
  # Orders

  @spec order(Order.t()) :: map()
  def order(%Order{} = order) do
    %{
      id: order.id,
      customer_id: order.customer,
      day_id: order.day_id,
      state: order.state,
      missing_information: order.missing_information,
      order_item_ids: order.items || [],
      items: order_items(order),
      created: encode_datetime(order.created),
      updated: encode_datetime(order.updated)
    }
  end

  defp order_items(order) do
    order
    |> expand_items()
    |> Enum.map(&order_item/1)
  end

  defp expand_items(order) do
    order
    |> Map.get(:expand, %{})
    |> Map.get(:items, [])
  end

  @spec order_item(OrderItem.t()) :: map()
  def order_item(%OrderItem{} = item) do
    %{
      id: item.id,
      item_id: item.item,
      customization_ids: item.customization || [],
      item: maybe_item(item),
      customizations: item_customizations(item),
      created: encode_datetime(item.created),
      updated: encode_datetime(item.updated)
    }
  end

  defp maybe_item(order_item) do
    order_item
    |> Map.get(:expand, %{})
    |> Map.get(:item)
    |> case do
      %Item{} = item -> item(item)
      _ -> nil
    end
  end

  defp item_customizations(order_item) do
    order_item
    |> Map.get(:expand, %{})
    |> Map.get(:customization, [])
    |> Enum.map(&item_customization/1)
  end

  # --------------------------------------------------------------------------
  # Menu customization helpers

  @spec item_customization(ItemCustomization.t()) :: map()
  def item_customization(%ItemCustomization{} = customization) do
    %{
      id: customization.id,
      key_id: customization.key,
      value_ids: customization.value || [],
      key: maybe_key(customization),
      values: maybe_values(customization),
      created: encode_datetime(customization.created),
      updated: encode_datetime(customization.updated)
    }
  end

  defp maybe_key(customization) do
    customization
    |> Map.get(:expand, %{})
    |> Map.get(:key)
    |> case do
      %CustomizationKey{} = key -> customization_key(key)
      _ -> nil
    end
  end

  defp maybe_values(customization) do
    customization
    |> Map.get(:expand, %{})
    |> Map.get(:value, [])
    |> Enum.map(fn
      %CustomizationValue{} = value -> customization_value(value)
      other -> render(other)
    end)
  end

  @spec customization_key(CustomizationKey.t()) :: map()
  def customization_key(%CustomizationKey{} = key) do
    %{
      id: key.id,
      name: key.name,
      enable: key.enable,
      label_color: key.label_color,
      default_value: key.default_value,
      multiple_choice: key.multiple_choice,
      sort_order: key.sort_order,
      created: encode_datetime(key.created),
      updated: encode_datetime(key.updated)
    }
  end

  @spec customization_value(CustomizationValue.t()) :: map()
  def customization_value(%CustomizationValue{} = value) do
    %{
      id: value.id,
      name: value.name,
      price_increment_nok: encode_decimal(value.price_increment_nok),
      constant_price: value.constant_price,
      belongs_to: value.belongs_to,
      enable: value.enable,
      sort_order: value.sort_order,
      created: encode_datetime(value.created),
      updated: encode_datetime(value.updated)
    }
  end

  # --------------------------------------------------------------------------
  # Menu entities

  @spec item(Item.t()) :: map()
  def item(%Item{} = item) do
    %{
      id: item.id,
      name: item.name,
      price_nok: encode_decimal(item.price_nok),
      category: item.category,
      image: item.image,
      enable: item.enable,
      sort_order: item.sort_order,
      created: encode_datetime(item.created),
      updated: encode_datetime(item.updated)
    }
  end

  @spec category(Category.t()) :: map()
  def category(%Category{} = category) do
    %{
      id: category.id,
      name: category.name,
      sort_order: category.sort_order,
      enable: category.enable,
      valid_customizations: category.valid_customizations || [],
      created: encode_datetime(category.created),
      updated: encode_datetime(category.updated)
    }
  end

  # --------------------------------------------------------------------------
  # Content entities

  @spec message(Message.t()) :: map()
  def message(%Message{} = message) do
    %{
      id: message.id,
      title: message.title,
      subtitle: message.subtitle,
      created: encode_datetime(message.created),
      updated: encode_datetime(message.updated)
    }
  end

  @spec status(Status.t()) :: map()
  def status(%Status{} = status) do
    %{
      id: status.id,
      open: status.open,
      show_message: status.show_message,
      message_id: status.message,
      message: maybe_status_message(status),
      created: encode_datetime(status.created),
      updated: encode_datetime(status.updated)
    }
  end

  defp maybe_status_message(status) do
    status
    |> Map.get(:expand, %{})
    |> Map.get(:message)
    |> case do
      %Message{} = message -> message(message)
      _ -> nil
    end
  end

  # --------------------------------------------------------------------------
  # Accounts

  @spec user(User.t()) :: map()
  def user(%User{} = user) do
    %{
      id: user.id,
      email: user.email,
      name: user.name,
      username: user.username,
      is_admin: user.is_admin,
      confirmed_at: encode_datetime(user.confirmed_at),
      created: encode_datetime(user.inserted_at),
      updated: encode_datetime(user.updated_at)
    }
  end

  # --------------------------------------------------------------------------
  # Helpers

  defp transform_value(value) when is_list(value), do: Enum.map(value, &transform_value/1)
  defp transform_value(%DateTime{} = datetime), do: encode_datetime(datetime)
  defp transform_value(%NaiveDateTime{} = datetime), do: encode_datetime(datetime)
  defp transform_value(%Date{} = date), do: Date.to_iso8601(date)
  defp transform_value(%Time{} = time), do: Time.to_iso8601(time)
  defp transform_value(%Decimal{} = decimal), do: encode_decimal(decimal)
  defp transform_value(%{__struct__: _} = struct), do: render(struct)
  defp transform_value(value), do: value

  defp encode_decimal(nil), do: nil
  defp encode_decimal(%Decimal{} = decimal), do: Decimal.to_float(decimal)

  defp encode_datetime(nil), do: nil
  defp encode_datetime(%NaiveDateTime{} = datetime), do: NaiveDateTime.to_iso8601(datetime)
  defp encode_datetime(%DateTime{} = datetime), do: DateTime.to_iso8601(datetime)
end
