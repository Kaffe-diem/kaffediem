defmodule Kaffebase.OrdersTest do
  use Kaffebase.DataCase

  import ExUnit.CaptureLog

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

      assert capture_log(fn ->
               assert {:error, %Ecto.Changeset{}} =
                        Orders.create_order(%{customer: user.id, items: [%{item: nil}]})
             end) =~ ""
    end

    test "returns error when referencing unknown existing order item" do
      user = AccountsFixtures.user_fixture()

      log =
        capture_log(fn ->
          assert {:error, changeset} =
                   Orders.create_order(%{customer: user.id, items: ["missing-order-item"]})

          assert %{items: messages} = errors_on(changeset)
          assert "references unknown order item" in messages
        end)

      assert log =~ "Order creation failed"
    end

    test "allows referencing an existing order item" do
      existing_order = OrdersFixtures.order_fixture()
      [existing_item_id | _] = existing_order.items
      user = AccountsFixtures.user_fixture()

      assert {:ok, order} = Orders.create_order(%{customer: user.id, items: [existing_item_id]})
      assert order.items == [existing_item_id]
    end

    test "rejects customizations for existing order item references" do
      existing_order = OrdersFixtures.order_fixture()
      [existing_item_id | _] = existing_order.items
      user = AccountsFixtures.user_fixture()
      customization_key = CatalogFixtures.customization_key_fixture()

      customization_value =
        CatalogFixtures.customization_value_fixture(%{key: customization_key})

      payload = %{
        customer: user.id,
        items: [
          %{
            order_item: existing_item_id,
            customizations: [%{key: customization_key.id, value: [customization_value.id]}]
          }
        ]
      }

      log =
        capture_log(fn ->
          assert {:error, changeset} = Orders.create_order(payload)
          assert %{items: [item_errors | _]} = errors_on(changeset)
          assert %{customizations: [message]} = item_errors
          assert String.contains?(message, "customizations")
        end)

      assert log =~ "Order payload invalid"
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

    test "preserves items when updating state" do
      user = AccountsFixtures.user_fixture()
      item = CatalogFixtures.item_fixture()

      {:ok, order} =
        Orders.create_order(%{
          customer: user.id,
          day_id: 100,
          state: "received",
          items: [%{item: item.id}]
        })

      # Verify order was created with items
      assert length(order.items) == 1

      # Update state without providing items
      {:ok, updated} = Orders.update_order_state(order, :production)

      # Items should still be present
      assert updated.state == :production
      assert length(updated.items) == 1

      # Verify items persist after reload
      reloaded = Orders.get_order!(updated.id)
      assert length(reloaded.items) == 1
      assert length(reloaded.expand.items) == 1
    end

    test "update_order preserves items when not provided" do
      user = AccountsFixtures.user_fixture()
      item = CatalogFixtures.item_fixture()

      {:ok, order} =
        Orders.create_order(%{
          customer: user.id,
          day_id: 101,
          items: [%{item: item.id}]
        })

      # Update only state, not items
      {:ok, updated} = Orders.update_order(order, %{state: "completed"})

      # Items should still be present
      assert updated.state == :completed
      assert length(updated.items) == 1
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

    test "filters by date range" do
      user = AccountsFixtures.user_fixture()
      item = CatalogFixtures.item_fixture()

      # Create order from yesterday
      {:ok, _old_order} =
        Orders.create_order(%{
          customer: user.id,
          day_id: 1,
          items: [%{item: item.id}]
        })
        |> tap(fn {:ok, order} ->
          Repo.update!(
            Ecto.Changeset.change(order, created: DateTime.add(DateTime.utc_now(), -2, :day))
          )
        end)

      # Create order from today
      {:ok, new_order} =
        Orders.create_order(%{
          customer: user.id,
          day_id: 2,
          items: [%{item: item.id}]
        })

      # Filter for today only
      today = Date.utc_today()
      results = Orders.list_orders(from_date: today)
      result_ids = Enum.map(results, & &1.id)

      assert new_order.id in result_ids
      refute Enum.any?(result_ids, &(&1 != new_order.id))
    end

    test "always preloads items without explicit option" do
      user = AccountsFixtures.user_fixture()
      item = CatalogFixtures.item_fixture()

      {:ok, order} =
        Orders.create_order(%{
          customer: user.id,
          day_id: 1,
          items: [%{item: item.id}]
        })

      # list_orders should automatically preload items
      [loaded] = Orders.list_orders() |> Enum.filter(&(&1.id == order.id))

      assert [%OrderItem{}] = loaded.expand.items
      assert loaded.expand.items |> hd() |> Map.get(:expand) |> Map.get(:item)
    end

    test "get_order! always preloads items" do
      user = AccountsFixtures.user_fixture()
      item = CatalogFixtures.item_fixture()

      {:ok, order} =
        Orders.create_order(%{
          customer: user.id,
          day_id: 1,
          items: [%{item: item.id}]
        })

      loaded = Orders.get_order!(order.id)

      assert [%OrderItem{}] = loaded.expand.items
      assert loaded.expand.items |> hd() |> Map.get(:expand) |> Map.get(:item)
    end
  end

  describe "create_order/1 broadcasts" do
    test "broadcasts order with preloaded items" do
      user = AccountsFixtures.user_fixture()
      item = CatalogFixtures.item_fixture()

      # create_order should broadcast the order with items preloaded
      {:ok, order} =
        Orders.create_order(%{
          customer: user.id,
          day_id: 1,
          items: [%{item: item.id}]
        })

      # The broadcast happens internally, but we can verify the order
      # returned from create_order has the structure expected for broadcast
      assert length(order.items) == 1

      # Verify that fetching the order also has items
      fetched = Orders.get_order!(order.id)
      assert length(fetched.expand.items) == 1
    end
  end
end
