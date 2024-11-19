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
    const initialOrders = await pb.collection("orders").getFullList({
      expand: "drinks, drinks.drink",
      filter: "state != 'dispatched'"
    });

    set(initialOrders.map(mapToOrder));

    pb.collection("orders").subscribe("*", (event) => {
      update((state) => {
        console.log({
          message: "received event on orders subscription",
          event: event,
          currentState: JSON.stringify(state, undefined, 2)
        });

        const orderIndex = state.findIndex((order) => order.id === event.record.id);

        const order = mapToOrder(event.record);

        switch (event.action) {
          case "create":
            state.push(order);
            break;
          case "update":
            pb.collection("order_drink").getFullList({
              filter: event.record.drinks.map((id: string) => `id="${id}"`).join("||"),
              expand: "drink"
            });
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
    add: async (order: string[]) => {
      const drinkIds: string[] = await Promise.all(
        // this mapping to create multiple order_drink with autocancellation disabled
        // equals a terrible idea
        // bulk / transactions coming in 0.23
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
    setState: (id: string, state: State) => {
      pb.collection("orders").update(id, { state });
    }
  };
};

export const orders = init();
