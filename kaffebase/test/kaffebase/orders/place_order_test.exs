defmodule Kaffebase.Orders.PlaceOrderTest do
  use Kaffebase.DataCase

  alias Kaffebase.AccountsFixtures
  alias Kaffebase.CatalogFixtures
  alias Kaffebase.Orders.PlaceOrder

  describe "new/1" do
    test "builds JSONB snapshot from catalog" do
      user = AccountsFixtures.user_fixture()
      item = CatalogFixtures.item_fixture()
      customization_key = CatalogFixtures.customization_key_fixture()

      customization_value =
        CatalogFixtures.customization_value_fixture(%{key: customization_key})

      payload = %{
        customer_id: user.id,
        missing_information: true,
        state: :completed,
        items: [
          %{
            item: item.id,
            customizations: [
              %{
                key: customization_key.id,
                value: [customization_value.id]
              }
            ]
          }
        ]
      }

      assert {:ok, command} = PlaceOrder.new(payload)
      assert command.customer_id == to_string(user.id)
      assert command.missing_information
      assert command.state == :completed

      [snapshot] = command.items
      assert snapshot[:item_id] == item.id
      assert snapshot[:name] == item.name
      assert snapshot[:price] == Decimal.to_string(item.price_nok)

      [customization] = snapshot[:customizations]
      assert customization[:key_id] == customization_key.id
      assert customization[:value_id] == customization_value.id
    end

    test "rejects payload without items" do
      assert {:error, changeset} = PlaceOrder.new(%{items: []})
      refute changeset.valid?
      assert %{items: messages} = errors_on(changeset)
      assert "is invalid" in messages
    end

    test "rejects invalid items" do
      payload = %{
        items: [
          %{item: nil}
        ]
      }

      assert {:error, changeset} = PlaceOrder.new(payload)
      refute changeset.valid?
      assert %{items: messages} = errors_on(changeset)
      assert "is invalid" in messages
    end
  end
end
