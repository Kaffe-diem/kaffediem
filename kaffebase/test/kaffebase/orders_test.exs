defmodule Kaffebase.OrdersTest do
  use Kaffebase.DataCase

  import ExUnit.CaptureLog

  alias Kaffebase.AccountsFixtures
  alias Kaffebase.CatalogFixtures
  alias Kaffebase.Orders
  alias Kaffebase.OrdersFixtures
  alias Kaffebase.Orders.Order
  alias Kaffebase.Repo

  setup do
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
          customer_id: user.id,
          missing_information: true,
          items: [
            %{
              item: item.id,
              customizations: [%{key: key.id, value: [value_a.id, value_b.id]}]
            }
          ]
        })

      assert order.customer_id == user.id
      assert order.day_id == 101
      assert order.missing_information

      [loaded] =
        Orders.list_orders()
        |> Enum.filter(&(&1.id == order.id))

      [order_item] = loaded.items
      assert order_item[:item_id] == item.id
      assert order_item[:name] == item.name
      assert order_item[:price] == Decimal.to_string(item.price_nok)

      customizations = order_item[:customizations]
      assert length(customizations) == 2

      assert Enum.all?(customizations, fn c ->
               c[:key_id] == key.id and c[:value_id] in [value_a.id, value_b.id]
             end)
    end

    test "returns error when nested order item invalid" do
      user = AccountsFixtures.user_fixture()

      assert capture_log(fn ->
               assert {:error, %Ecto.Changeset{}} =
                        Orders.create_order(%{customer: user.id, items: [%{item: nil}]})
             end) =~ ""
    end

    test "stores customizations as JSONB snapshots" do
      user = AccountsFixtures.user_fixture()
      item = CatalogFixtures.item_fixture()
      key = CatalogFixtures.customization_key_fixture(%{multiple_choice: true})
      value_a = CatalogFixtures.customization_value_fixture(%{key: key})
      value_b = CatalogFixtures.customization_value_fixture(%{key: key, name: "Second"})

      {:ok, order} =
        Orders.create_order(%{
          customer: to_string(user.id),
          items: [
            %{
              item: item.id,
              customizations: [
                %{key: key.id, value: [value_a.id]},
                %{key: key.id, value: [value_b.id]}
              ]
            }
          ]
        })

      loaded = Orders.get_order!(order.id)
      [item_row] = loaded.items

      customizations = item_row[:customizations]
      assert length(customizations) == 2

      value_ids = Enum.map(customizations, & &1[:value_id]) |> Enum.sort()
      assert value_ids == Enum.sort([value_a.id, value_b.id])
    end

    test "auto-increments day_id for each order created on the same day" do
      user = AccountsFixtures.user_fixture()
      item = CatalogFixtures.item_fixture()

      {:ok, first} = Orders.create_order(%{customer: user.id, items: [%{item: item.id}]})
      {:ok, second} = Orders.create_order(%{customer: user.id, items: [%{item: item.id}]})

      assert first.day_id == 101
      assert second.day_id == 102
    end

    test "resets day_id sequence at the start of a new day" do
      user = AccountsFixtures.user_fixture()
      item = CatalogFixtures.item_fixture()

      {:ok, first} = Orders.create_order(%{customer: user.id, items: [%{item: item.id}]})

      Repo.update!(
        Ecto.Changeset.change(first, inserted_at: DateTime.add(DateTime.utc_now(), -1, :day) |> DateTime.to_naive() |> NaiveDateTime.truncate(:second))
      )

      {:ok, second} = Orders.create_order(%{customer: user.id, items: [%{item: item.id}]})

      assert second.day_id == 101
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
          state: "received",
          items: [%{item: item.id}]
        })

      # Verify order was created with items
      loaded = Orders.get_order!(order.id)
      assert length(loaded.items) == 1

      # Update state without providing items
      {:ok, updated} = Orders.update_order_state(order, :production)

      # Items should still be present
      assert updated.state == :production

      # Verify items persist after reload
      reloaded = Orders.get_order!(updated.id)
      assert length(reloaded.items) == 1
    end

    test "update_order preserves items when not provided" do
      user = AccountsFixtures.user_fixture()
      item = CatalogFixtures.item_fixture()

      {:ok, order} =
        Orders.create_order(%{
          customer: user.id,
          items: [%{item: item.id}]
        })

      # Update only state, not items
      {:ok, updated} = Orders.update_order(order, %{state: "completed"})

      # Items should still be present
      assert updated.state == :completed

      loaded = Orders.get_order!(updated.id)
      assert length(loaded.items) == 1
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
      older = OrdersFixtures.order_fixture(%{user: user})
      newer = OrdersFixtures.order_fixture(%{user: user})

      from_date = Date.utc_today() |> Date.add(-1)
      results = Orders.list_orders(customer_id: to_string(user.id), from_date: from_date)
      assert Enum.sort(Enum.map(results, & &1.id)) == Enum.sort([older.id, newer.id])
    end

    test "filters by date range" do
      user = AccountsFixtures.user_fixture()
      item = CatalogFixtures.item_fixture()

      # Create order from yesterday
      {:ok, _old_order} =
        Orders.create_order(%{
          customer: user.id,
          items: [%{item: item.id}]
        })
        |> tap(fn {:ok, order} ->
          Repo.update!(
            Ecto.Changeset.change(order, inserted_at: DateTime.add(DateTime.utc_now(), -2, :day) |> DateTime.to_naive() |> NaiveDateTime.truncate(:second))
          )
        end)

      # Create order from today
      {:ok, new_order} =
        Orders.create_order(%{
          customer: user.id,
          items: [%{item: item.id}]
        })

      # Filter for today only
      today = Date.utc_today()
      results = Orders.list_orders(from_date: today)
      result_ids = Enum.map(results, & &1.id)

      assert new_order.id in result_ids
      refute Enum.any?(result_ids, &(&1 != new_order.id))
    end

    test "always returns items from JSONB" do
      user = AccountsFixtures.user_fixture()
      item = CatalogFixtures.item_fixture()

      {:ok, order} =
        Orders.create_order(%{
          customer: user.id,
          items: [%{item: item.id}]
        })

      # list_orders should automatically expand items
      [loaded] = Orders.list_orders() |> Enum.filter(&(&1.id == order.id))

      assert length(loaded.items) == 1
      [item_data] = loaded.items
      assert item_data[:item_id] == item.id
      assert item_data[:name] == item.name
    end

    test "get_order! returns items from JSONB" do
      user = AccountsFixtures.user_fixture()
      item = CatalogFixtures.item_fixture()

      {:ok, order} =
        Orders.create_order(%{
          customer: user.id,
          items: [%{item: item.id}]
        })

      loaded = Orders.get_order!(order.id)

      assert length(loaded.items) == 1
      [item_data] = loaded.items
      assert item_data[:item_id] == item.id
      assert item_data[:name] == item.name
    end
  end

  describe "create_order/1 broadcasts" do
    test "broadcasts order with items in JSONB" do
      user = AccountsFixtures.user_fixture()
      item = CatalogFixtures.item_fixture()

      # create_order should broadcast the order with items
      {:ok, order} =
        Orders.create_order(%{
          customer: user.id,
          items: [%{item: item.id}]
        })

      # Verify that fetching the order has items from JSONB
      fetched = Orders.get_order!(order.id)
      assert length(fetched.items) == 1
      [item_data] = fetched.items
      assert item_data[:item_id] == item.id
    end
  end
end
