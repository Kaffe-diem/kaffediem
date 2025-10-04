defmodule Kaffebase.OrdersTest do
  use Kaffebase.DataCase

  alias Kaffebase.AccountsFixtures
  alias Kaffebase.CatalogFixtures
  alias Kaffebase.Orders
  alias Kaffebase.OrdersFixtures
  alias Kaffebase.Orders.{Order, OrderItem}
  alias Kaffebase.Repo

  setup do
    Repo.delete_all(OrderItem)
    Repo.delete_all(Order)
    :ok
  end

  describe "create_order/1" do
    test "persists order with nested items and customizations" do
      user = AccountsFixtures.user_fixture()
      item = CatalogFixtures.item_fixture()
      key = CatalogFixtures.customization_key_fixture()
      value_a = CatalogFixtures.customization_value_fixture(%{key: key})
      value_b = CatalogFixtures.customization_value_fixture(%{key: key, name: "Another"})

      {:ok, order} =
        Orders.create_order(%{
          customer: user.id,
          day_id: 123,
          missing_information: true,
          items: [
            %{
              item: item.id,
              customizations: [%{key: key.id, value: [value_a.id, value_b.id]}]
            }
          ]
        })

      assert order.customer == user.id
      assert order.day_id == 123
      assert order.missing_information
      assert length(order.items) == 1

      [loaded] =
        Orders.list_orders(preload: [:items, :item_records, :customizations])
        |> Enum.filter(&(&1.id == order.id))

      [order_item] = loaded.expand.items
      assert order_item.item == item.id
      assert order_item.expand.item.id == item.id
      [customization] = order_item.expand.customization
      assert customization.key == key.id
      assert Enum.sort(customization.value) == Enum.sort([value_a.id, value_b.id])
      assert customization.expand.key.id == key.id

      assert Enum.map(customization.expand.value, & &1.id) |> Enum.sort() ==
               Enum.sort([value_a.id, value_b.id])
    end

    test "returns error when nested order item invalid" do
      user = AccountsFixtures.user_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Orders.create_order(%{customer: user.id, items: [%{item: nil}]})
    end
  end

  describe "update_order/2" do
    test "updates state and missing_information" do
      order = OrdersFixtures.order_fixture()

      {:ok, updated} =
        Orders.update_order(order, %{state: "completed", missing_information: true})

      assert updated.state == :completed
      assert updated.missing_information
    end
  end

  describe "update_order_state/2" do
    test "sets provided state" do
      order = OrdersFixtures.order_fixture()
      {:ok, updated} = Orders.update_order_state(order, :dispatched)
      assert updated.state == :dispatched
    end

    test "set_all_orders_state/1 updates all rows" do
      OrdersFixtures.order_fixture()
      OrdersFixtures.order_fixture()

      {count, _} = Orders.set_all_orders_state("production")
      assert count >= 2
      assert Enum.all?(Orders.list_orders(), &(&1.state == :production))
    end
  end

  describe "list_orders/1" do
    test "filters by customer and from_date" do
      user = AccountsFixtures.user_fixture()
      older = OrdersFixtures.order_fixture(%{user: user, day_id: 1})
      newer = OrdersFixtures.order_fixture(%{user: user, day_id: 2})

      from_date = Date.utc_today() |> Date.add(-1)
      results = Orders.list_orders(customer_id: user.id, from_date: from_date)
      assert Enum.sort(Enum.map(results, & &1.id)) == Enum.sort([older.id, newer.id])
    end

    test "preload: [:items] attaches expand map" do
      order = OrdersFixtures.order_fixture()
      [loaded] = Orders.list_orders(preload: [:items]) |> Enum.filter(&(&1.id == order.id))
      assert [%OrderItem{}] = loaded.expand.items
    end
  end
end
