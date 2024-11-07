import { PUBLIC_PB_HOST } from "$env/static/public";
import { writable } from "svelte/store";
import pocketbase from "pocketbase";
import { Order } from "$lib/types";
import type { State } from "$lib/types";

// ref: https://github.com/pocketbase/js-sdk?tab=readme-ov-file#nodejs-via-npm
import eventsource from "eventsource";
// eslint-disable-next-line @typescript-eslint/no-explicit-any
(global as any).EventSource = eventsource;

const pb = new pocketbase(PUBLIC_PB_HOST);

const mapToOrder = (data: unknown): Order => {
  return new Order({
    id: data.id,
    state: data.state,
    collectionId: data.collectionId,
    collectionName: data.collectionName,
    created: data.created,
    customer: data.customer,
    drinks: data.drinks,
    payment_fulfilled: data.payment_fulfilled,
    updated: data.updated
  });
};

const init = () => {
  const { subscribe, set, update } = writable<Order[]>([]);

  (async () => {
    const initialOrders = await pb.collection("orders").getFullList();
    set(initialOrders.map(mapToOrder));

    pb.collection("orders").subscribe("*", (e) => {
      update((state) => {
        console.log({
          message: "received event on orders subscription",
          event: e,
          currentState: state
        });

        const orderIndex = state.findIndex((order) => order.id === e.record.id);

        const order = mapToOrder(e.record);

        switch (e.action) {
          case "create":
            state.push(order);
            break;
          case "update":
            state[orderIndex] = order;
            break;
          case "delete":
            state.splice(orderIndex, 1);
            break;
        }

        return state;
      });
    });
  })();

  return {
    subscribe,
    add: (_order: Order) => {
      // create 'received' order
      // think: this order will be received immediately by the subscription, so no need to update state
      // however, we can use the interim state to show a sent but not received order. depending on latency, we need to add it anyway.
      pb.collection("orders").create({
        customer: pb.authStore.model?.id,
        drinks: ["csw4j2vfl41d6pq"],
        state: "complete"
      });
    }
  };
};

export const orders = init();
