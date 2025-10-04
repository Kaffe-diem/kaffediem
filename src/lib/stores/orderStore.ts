import { createCollectionStore, sendCollectionRequest } from "$stores/websocketStore";
import * as _ from "$lib/utils";
import { Collections, type RecordIdString, State, Order, CustomizationValue } from "$lib/types";
import auth from "$stores/authStore";
import { get } from "svelte/store";
import { type CartItem } from "$stores/cartStore";
import { toasts } from "$lib/stores/toastStore";

const today = new Date().toISOString().split("T")[0];

const baseOptions = {
  expand: [
    "items",
    "items.item",
    "items.customization",
    "items.customization.key",
    "items.customization.value"
  ].join(","),
  filter: `created >= "${today}"`
};

const actionHistory: {
  action: "updateState";
  orderId: RecordIdString;
  previousState: State;
}[] = [];

const rawOrdersStore = createCollectionStore(
  Collections.Order,
  {
    fromWire: Order.fromPb
  },
  baseOptions
);

export const raw_orders = rawOrdersStore;

const buildCustomizationPayload = (customizations: CustomizationValue[]) =>
  Object.entries(_.groupBy(customizations, (customization) => customization.belongsTo)).map(
    ([keyId, values]) => ({
      key: keyId,
      value: values.map((value) => value.id)
    })
  );

export default {
  subscribe: rawOrdersStore.subscribe,
  destroy: rawOrdersStore.destroy,
  reset: () => undefined,

  create: async (
    userId: RecordIdString,
    items: CartItem[],
    missingInformation: boolean,
    dayId: number
  ) => {
    const payload = {
      customer: userId,
      items: items.map((item) => ({
        item: item.id,
        customizations: buildCustomizationPayload(item.customizations ?? [])
      })),
      state: State.received,
      missing_information: missingInformation,
      day_id: dayId
    };

    await sendCollectionRequest("POST", Collections.Order, null, payload);

    const orders = get(rawOrdersStore)
      .slice()
      .sort((a, b) => a.dayId - b.dayId);
    const orderNumber = orders.at(-1)?.dayId;
    if (orderNumber) {
      toasts.success(orderNumber.toString(), 1500);
    }
  },

  updateState: async (orderId: RecordIdString, state: State) => {
    const existing = get(rawOrdersStore).find((order) => order.id === orderId);

    if (existing) {
      actionHistory.push({
        action: "updateState",
        orderId: orderId,
        previousState: existing.state
      });
    }

    await sendCollectionRequest("PATCH", Collections.Order, orderId, { state });
  },

  setAll: async (state: State) => {
    const orders = get(rawOrdersStore);
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

export const userOrders = createCollectionStore(
  Collections.Order,
  {
    fromWire: Order.fromPb
  },
  {
    ...baseOptions,
    filter: `customer = '${get(auth).user.id}'`
  }
);
