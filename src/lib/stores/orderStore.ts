import { createCollectionCrud, sendCollectionRequest } from "$stores/websocketStore";
import { Collections, type RecordIdString, State, Order } from "$lib/types";
import { get } from "svelte/store";
import { type CartItem } from "$stores/cartStore";

const actionHistory: {
  action: "updateState";
  orderId: RecordIdString;
  previousState: State;
}[] = [];

const getTodayISO = () => {
  const [date] = new Date().toISOString().split("T");
  return date || "";
};

const ordersStore = createCollectionCrud(
  Collections.Order,
  {
    fromWire: Order.fromApi
  },
  {
    from_date: getTodayISO()
  }
);

export const raw_orders = ordersStore;

const serializeCartItems = (items: CartItem[]) =>
  items.map((item) => ({
    item: item.id,
    customizations: (item.customizations ?? [])
      .filter((customization) => Boolean(customization.belongsTo))
      .map((customization) => ({
        key_id: customization.belongsTo!,
        value: customization.id
      }))
  }));

export default {
  ...ordersStore,
  reset: ordersStore.reset,

  create: async (userId: RecordIdString, items: CartItem[], missingInformation: boolean) => {
    const payload = {
      customer: userId,
      items: serializeCartItems(items),
      state: State.received,
      missing_information: missingInformation
    };

    await sendCollectionRequest("POST", Collections.Order, null, payload);
  },

  updateState: async (orderId: RecordIdString, state: State) => {
    const existing = get(ordersStore).find((order) => order.id === orderId);

    if (existing) {
      actionHistory.push({
        action: "updateState",
        orderId: orderId,
        previousState: existing.state as State
      });
    }

    await sendCollectionRequest("PATCH", Collections.Order, orderId, { state });
  },

  setAll: async (state: State) => {
    const orders = get(ordersStore);
    await Promise.all(
      orders.map((order) => sendCollectionRequest("PATCH", Collections.Order, order.id, { state }))
    );
  },

  undoLastAction: async () => {
    if (actionHistory.length === 0) {
      return;
    }

    const lastAction = actionHistory.pop();

    if (lastAction?.action === "updateState") {
      await sendCollectionRequest("PATCH", Collections.Order, lastAction.orderId, {
        state: lastAction.previousState
      });
    }
  }
};
