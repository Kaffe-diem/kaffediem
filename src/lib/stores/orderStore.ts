import { createGenericPbStore, createPbStore } from "$stores/pbStore";
import pb, { Collections, type RecordIdString } from "$lib/pocketbase";
import { State, Order } from "$lib/types";
import auth from "$stores/authStore";
import { get } from "svelte/store";

const today = new Date().toISOString().split("T")[0];

const baseOptions = {
  //   Table `item`
  // + col `item` which references `order_item`
  expand: "items,items.item",
  filter: `created >= "${today}"`
};

export default {
  subscribe: createPbStore(Collections.Order, Order, baseOptions),

  create: async (userId: RecordIdString, itemIds: RecordIdString[]) => {
    const getOrderItemIds = async (): Promise<RecordIdString[]> => {
      return await Promise.all(
        itemIds.map(async (itemId) => {
          const response = await pb.collection(Collections.OrderItem).create({ item: itemId });
          return response.id;
        })
      );
    };

    await pb.collection(Collections.Order).create({
      customer: userId,
      items: await getOrderItemIds(),
      state: State.received,
      payment_fulfilled: false
    });
  },

  updateState: (orderId: RecordIdString, state: State) => {
    pb.collection(Collections.Order).update(orderId, { state });
  }
};

export const userOrders = createGenericPbStore(Collections.Order, Order, {
  ...baseOptions,
  filter: `customer = '${get(auth).user.id}'`
});
