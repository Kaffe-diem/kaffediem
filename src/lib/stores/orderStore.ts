import createPbStore from "$stores/pbStore";
import pb from "$lib/pocketbase";
import { OrderDrink, Order } from "$lib/types";
import type { State } from "$lib/types";
import { mapToItem } from "$stores/menuStore";

const mapToOrderDrink = (data: { id: string; expand: unknown }): OrderDrink =>
  new OrderDrink({
    id: data.id,
    // @ts-expect-error Pocketbase typing not implemented yet
    name: data.expand.drink.name,
    // @ts-expect-error Pocketbase typing not implemented yet
    item: mapToItem(data.expand.drink)
  });

// Typing is not entirely correct. FIXME when implementing proper typing
const mapToOrder = (data: { id: string; state: State; expand: unknown }): Order =>
  new Order({
    id: data.id,
    state: data.state,
    // @ts-expect-error Pocketbase typing not implemented yet
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
      order.map(async (id: string) => {
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
  updateState: (id: string, state: State) => {
    pb.collection("orders").update(id, { state });
  }
};

export const userOrders = {
  subscribe: createPbStore<Order>("orders", mapToOrder, {
    expand: "drinks, drinks.drink",
    filter: `customer = '${pb.authStore.model?.id}'`
  })
};
