import { PUBLIC_PB_HOST } from "$env/static/public";
import { writable } from "svelte/store";
import pocketbase from "pocketbase";

// ref: https://github.com/pocketbase/js-sdk?tab=readme-ov-file#nodejs-via-npm
import eventsource from "eventsource";
// eslint-disable-next-line @typescript-eslint/no-explicit-any
(global as any).EventSource = eventsource;

const pb = new pocketbase(PUBLIC_PB_HOST);

export const orders = writable([]);

const init = async () => {
  const initialOrders = await pb.collection("orders").getFullList();
  orders.set(initialOrders);

  pb.collection("orders").subscribe("*", (e) => {
    orders.update((state) => {
      console.log({
        message: "received event on orders subscription",
        event: e,
        currentState: state
      });

      const orderIndex = state.findIndex((order) => order.id === e.record.id);

      switch (e.action) {
        case "create":
          state.push(e.record);
          break;
        case "update":
          state[orderIndex] = e.record;
          break;
        case "delete":
          state.splice(orderIndex, 1);
          break;
      }

      return state;
    });
  });
};

init();
