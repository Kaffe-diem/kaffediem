import pb from "$lib/pocketbase";
import { writable } from "svelte/store";
import { Drink, Order } from "$lib/types";
import type { State } from "$lib/types";

// ref: https://github.com/pocketbase/js-sdk?tab=readme-ov-file#nodejs-via-npm
import eventsource from "eventsource";
// eslint-disable-next-line @typescript-eslint/no-explicit-any
(global as any).EventSource = eventsource;

const mapToDrink = (data: unknown): Drink => {
  return new Drink({
    // @ts-expect-error Pocketbase typing not implemented yet
    name: data.expand.drink.name
  });
};

// Typing is not entirely correct. FIXME when implementing proper typing
const mapToOrder = (data: { id: string; state: State; expand: unknown }): Order => {
  return new Order({
    id: data.id,
    state: data.state,
    // @ts-expect-error Pocketbase typing not implemented yet
    drinks: data.expand.drinks.map(mapToDrink)
  });
};

const init = () => {
  const { subscribe, set, update } = writable<Order[]>([]);

  (async () => {
    const initialOrders = await pb.collection("orders").getFullList({
      expand: "drinks, drinks.drink",
      filter: "state != 'dispatched'"
    });

    // @ts-expect-error Pocketbase typing not implemented yet
    set(initialOrders.map(mapToOrder));

    pb.collection("orders").subscribe(
      "*",
      (event) => {
        update((state) => {
          // console.log({
          //   message: "received event on orders subscription",
          //   event: event,
          //   currentState: JSON.stringify(state, undefined, 2)
          // });

          const orderIndex = state.findIndex((order) => order.id === event.record.id);

          // @ts-expect-error Pocketbase typing not implemented yet
          const order = mapToOrder(event.record);

          switch (event.action) {
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
      },
      {
        expand: "drinks, drinks.drink"
      }
    );
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
