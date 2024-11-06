import { PUBLIC_PB_HOST } from "$env/static/public";
import { writable } from "svelte/store";
import pocketbase from "pocketbase";

// ref: https://github.com/pocketbase/js-sdk?tab=readme-ov-file#nodejs-via-npm
import eventsource from "eventsource";
// eslint-disable-next-line @typescript-eslint/no-explicit-any
(global as any).EventSource = eventsource;

const pb = new pocketbase(PUBLIC_PB_HOST);

export const orderStore = writable([]);

const init = async () => {
  const orders = await pb.collection("orders").getFullList();
  orderStore.set(orders);

  pb.collection("orders").subscribe("*", (e) => {
    orderStore.update((state) => {
      const updatedState = [...state];
      const orderIndex = updatedState.findIndex((order) => order.id === e.record.id);

      if (e.action === "create") {
        if (orderIndex === -1) {
          updatedState.push(e.record);
        }
      } else if (e.action === "update") {
        if (orderIndex !== -1) {
          updatedState[orderIndex] = e.record;
        }
      } else if (e.action === "delete") {
        if (orderIndex !== -1) {
          updatedState.splice(orderIndex, 1);
        }
      }

      return updatedState;
    });
  });
};

init();
