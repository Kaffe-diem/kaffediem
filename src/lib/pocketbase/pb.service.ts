import { writable } from "svelte/store";
import pocketbase from "pocketbase";

// ref: https://github.com/pocketbase/js-sdk?tab=readme-ov-file#nodejs-via-npm
import eventsource from "eventsource";
// eslint-disable-next-line @typescript-eslint/no-explicit-any
(global as any).EventSource = eventsource;

import * as pbt from "./pb.d";

// should probablt be moved away from here. also, stores don't have a length?
export const ordersStore = writable([])
export const pb = new pocketbase(process.env.PUBLIC_PB_HOST)

export const OrderService = {
  createOrder: async () => {
    const orderDrinkIds = [(await OrderService._createOrderDrink()).id];

    return pb.collection("orders").create({
      drinks: orderDrinkIds,
      // admin does not work, as its not stored in users collection.
      // so this is hardcoded to a random user. todo.
      customer: "yl4tj93hwcsziys",
      order_fulfilled: false,
      payment_fulfilled: false
    });
  },

  _createOrderDrink: async () => {
    return pb.collection("order_drink").create({
      drink: "w72i4rxynu94w35",
      milk: pbt.OrderDrinkMilkOptions.whole,
      serving_size: pbt.OrderDrinkServingSizeOptions.big,
      extras: [pbt.OrderDrinkExtrasOptions.cream],
      flavor: [pbt.OrderDrinkFlavorOptions.irish]
    });
  },

  listenForOrders: async () => {
    // Populate the initial store
    const orders = await pb.collection("orders").getFullList();
    ordersStore.set(orders);

    // Listen for changes
    pb.collection("orders").subscribe("*", (e) => {
      ordersStore.update((currentOrders) => {
        const orderIndex = currentOrders.findIndex(
          (order: pbt.OrdersResponse) => order.id === e.record.id
        );
        if (orderIndex !== -1) {
          currentOrders[orderIndex] = e.record;
        } else {
          currentOrders.push(e.record);
        }
        return currentOrders;
      });
    });
    return ordersStore;
  }
};
