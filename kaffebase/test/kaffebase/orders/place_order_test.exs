defmodule Kaffebase.Orders.Commands.PlaceOrderTest do
  use Kaffebase.DataCase

  alias Kaffebase.AccountsFixtures
  alias Kaffebase.CatalogFixtures
  alias Kaffebase.Orders.Commands.PlaceOrder

  describe "new/1" do
    test "normalizes nested payload" do
      user = AccountsFixtures.user_fixture()
      item = CatalogFixtures.item_fixture()
      customization_key = CatalogFixtures.customization_key_fixture()

      customization_value =
        CatalogFixtures.customization_value_fixture(%{key: customization_key})

      payload = %{
        "customer" => %{"id" => user.id},
        "day_id" => "42",
        "missing_information" => "true",
        "state" => "COMPLETED",
        "items" => [
          %{
            "item" => item.id,
            "customizations" => [
              %{
                "key" => customization_key.id,
                "value" => [customization_value.id]
              }
            ]
          }
        ]
      }

      assert {:ok, command} = PlaceOrder.new(payload)
      assert command.customer_id == user.id
      assert command.day_id == 42
      assert command.missing_information
      assert command.state == :completed

      [entry] = command.items
      assert entry.item_id == item.id
      refute entry.existing_order_item_id

      [selection] = entry.customizations
      assert selection.key_id == customization_key.id
      assert selection.value_ids == [customization_value.id]
    end

    test "rejects payload without items" do
      assert {:error, changeset} = PlaceOrder.new(%{"items" => []})
      refute changeset.valid?
      assert %{items: messages} = errors_on(changeset)
      assert Enum.any?(messages, &String.contains?(&1, "blank"))
    end

    test "rejects payload mixing existing reference and new item" do
      item = CatalogFixtures.item_fixture()

      payload = %{
        "items" => [
          %{"item" => item.id, "order_item" => "existing"}
        ]
      }

      assert {:error, changeset} = PlaceOrder.new(payload)
      refute changeset.valid?
      assert %{items: [_ | _]} = errors_on(changeset)
    end
  end
end
