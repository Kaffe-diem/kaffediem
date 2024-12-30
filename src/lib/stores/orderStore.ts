import createPbStore from "$stores/pbStore";
import pb, { Collections, type RecordIdString } from "$lib/pocketbase";
import { State, Order, User } from "$lib/types";

const today = new Date().toISOString().split("T")[0];

const baseOptions = {
  expand: "drinks,drinks.drink",
  filter: `created >= "${today}"`
};

export default {
  subscribe: createPbStore(Collections.Orders, Order, baseOptions),

  create: async (itemIds: RecordIdString[]) => {
    const getOrderItemIds = async (): Promise<RecordIdString[]> => {
      return await Promise.all(
        itemIds.map(async (itemId) => {
          const response = await pb.collection(Collections.OrderDrink).create({ drink: itemId });
          return response.id;
        })
      );
    };

    await pb.collection(Collections.Orders).create({
      customer: User.fromPb().id,
      drinks: await getOrderItemIds(),
      state: State.received,
      payment_fulfilled: false
    });
  },

  updateState: (orderId: RecordIdString, state: State) => {
    pb.collection(Collections.Orders).update(orderId, { state });
  }
};
export const userOrders = {
  subscribe: createPbStore(Collections.Orders, Order, {
    ...baseOptions,
    filter: `customer = '${User.fromPb().id}'`
  })
};
