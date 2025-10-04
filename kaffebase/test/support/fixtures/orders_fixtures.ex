defmodule Kaffebase.OrdersFixtures do
  @moduledoc false

  alias Kaffebase.AccountsFixtures
  alias Kaffebase.CatalogFixtures
  alias Kaffebase.Orders

  def order_fixture(attrs \\ %{}) do
    user = Map.get_lazy(attrs, :user, fn -> AccountsFixtures.user_fixture() end)
    item = Map.get_lazy(attrs, :item, fn -> CatalogFixtures.item_fixture() end)
    customizations = Map.get(attrs, :customizations, [])

    default_item_payload = %{
      item: item.id,
      customizations: customizations
    }

    payload = %{
      customer: user.id,
      day_id: Map.get(attrs, :day_id, 1),
      missing_information: Map.get(attrs, :missing_information, false),
      items: [Map.merge(default_item_payload, Map.get(attrs, :item_attrs, %{}))]
    }

    {:ok, order} =
      attrs
      |> Map.drop([:user, :item, :customizations, :item_attrs])
      |> Enum.into(payload)
      |> Orders.create_order()

    order
  end
end
