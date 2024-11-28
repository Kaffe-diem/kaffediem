import createPbStore from "$stores/pbStore";
import pb from "$lib/pocketbase";
import { OrderDrink, Order } from "$lib/types";
import type { ExpandedOrderRecord, ExpandedOrderDrinkRecord } from "$lib/types";
import type { State } from "$lib/types";
import { mapToItem } from "$stores/menuStore";
import type { RecordIdString } from "$lib/pb-types";

const mapToOrderDrink = (data: ExpandedOrderDrinkRecord): OrderDrink =>
  new OrderDrink({
    id: data.id,
    name: data.expand.drink.name,
    item: mapToItem(data.expand.drink)
  });

const mapToOrder = (data: ExpandedOrderRecord): Order =>
  new Order({
    id: data.id,
    state: data.state,
    drinks: data.expand.drinks.map(mapToOrderDrink)
  });

const today = new Date().toISOString().split("T")[0];
export default {
  subscribe: createPbStore<Order>(
    "orders",
    mapToOrder,
    {
      expand: "drinks, drinks.drink",
      filter: `created >= "${today}"`
    },
    {
      expand: "drinks, drinks.drink"
    }
  ),
  create: async (order: string[]) => {
    const drinkIds: string[] = await Promise.all(
      // FIXME: Use transactions
      // https://github.com/pocketbase/pocketbase/issues/5386
      order.map(async (id: RecordIdString) => {
        const response = await pb.collection("order_drink").create(
          {
            drink: id
          },
          {
            $autoCancel: false
          }
        );

        return response.id;
      })
    );

    await pb.collection("orders").create({
      customer: pb.authStore.model?.id,
      drinks: drinkIds,
      state: "received",
      payment_fulfilled: false
    });
  },
  updateState: (id: RecordIdString, state: State) => {
    pb.collection("orders").update(id, { state });
  }
};

export const userOrders = {
  subscribe: createPbStore<Order>("orders", mapToOrder, {
    expand: "drinks, drinks.drink",
    filter: `customer = '${pb.authStore.model?.id}'`
  })
};
