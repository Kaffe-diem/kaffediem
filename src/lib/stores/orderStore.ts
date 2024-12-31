import createPbStore from "$stores/pbStore";
import pb, { Collections, type RecordIdString } from "$lib/pocketbase";
import { State, Order, type ExpandedOrderRecord } from "$lib/types";
import auth from "$stores/authStore";
import { get, writable } from "svelte/store";

const today = new Date().toISOString().split("T")[0];

const baseOptions = {
  expand: "drinks,drinks.drink",
  filter: `created >= "${today}"`
};

// FIXME: implement orderStore correctly instead of copying pbStore and removing returns
function createOrderStore() {
  const { subscribe, set, update } = writable<Order[]>([]);

  (async () => {
    const initialData: ExpandedOrderRecord[] = await pb
      .collection(Collections.Orders)
      .getFullList(baseOptions);
    set(initialData.map((order) => Order.fromPb(order)));

    pb.collection(Collections.Orders).subscribe(
      "*",
      (event: { record: ExpandedOrderRecord; action: string }) => {
        update((state) => {
          const itemIndex = state.findIndex((item) => item.id == event.record.id);
          const item = Order.fromPb(event.record);

          switch (event.action) {
            case "create":
              state.push(item);
              break;
            case "update":
              if (itemIndex !== -1) state[itemIndex] = item;
              break;
            case "delete":
              if (itemIndex !== -1) state.splice(itemIndex, 1);
              break;
          }

          return state;
        });
      },
      baseOptions
    );
  })();

  return subscribe;
}

export default {
  subscribe: createOrderStore(),

  create: async (userId: RecordIdString, itemIds: RecordIdString[]) => {
    const getOrderItemIds = async (): Promise<RecordIdString[]> => {
      return await Promise.all(
        itemIds.map(async (itemId) => {
          const response = await pb.collection(Collections.OrderDrink).create({ drink: itemId });
          return response.id;
        })
      );
    };

    await pb.collection(Collections.Orders).create({
      customer: userId,
      drinks: await getOrderItemIds(),
      state: State.received,
      payment_fulfilled: false
    });
  },

  updateState: (orderId: RecordIdString, state: State) => {
    pb.collection(Collections.Orders).update(orderId, { state });
  }
};

export const userOrders = createPbStore(Collections.Orders, Order, {
  ...baseOptions,
  filter: `customer = '${get(auth).user.id}'`
});
