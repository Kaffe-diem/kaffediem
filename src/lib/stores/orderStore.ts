import { createGenericPbStore, createPbStore } from "$stores/pbStore";
import * as _ from "$lib/utils";
import pb, { Collections, type RecordIdString } from "$lib/pocketbase";
import { State, Order, CustomizationValue } from "$lib/types";
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
  action: string;
  orderId: RecordIdString;
  orderItemIds?: RecordIdString[];
  previousState?: State;
}[] = [];

// Create the store so we can reference it in methods
const _subscribe = createPbStore(Collections.Order, Order, baseOptions);

export default {
  subscribe: _subscribe,

  create: async (userId: RecordIdString, items: CartItem[]) => {
    const orderItemIds = await Promise.all(
      items.map(async (item) => {
        const orderItemResponse = await pb.collection(Collections.OrderItem).create({
          item: item.id
        });

        if (!_.isEmpty(item.customizations)) {
          await attachCustomizationsToOrderItem(orderItemResponse.id, item.customizations);
        }

        return orderItemResponse.id;
      })
    );

    const order = await pb.collection(Collections.Order).create({
      customer: userId,
      items: orderItemIds,
      state: State.received,
      payment_fulfilled: false
    });

    actionHistory.push({
      action: "create",
      orderId: order.id,
      orderItemIds: orderItemIds
    });

    const _orderStore = get({ subscribe: _subscribe });
    const orderNumber = _orderStore.length + 100 - 1;

    toasts.success(`✅ ${orderNumber}`);
  },

  updateState: async (orderId: RecordIdString, state: State) => {
    const order = await pb.collection(Collections.Order).getOne(orderId);

    actionHistory.push({
      action: "updateState",
      orderId: orderId,
      previousState: order.state
    });

    await pb.collection(Collections.Order).update(orderId, { state });
  },

  undoLastAction: async () => {
    if (actionHistory.length === 0) {
      return;
    }

    const lastAction = actionHistory.pop();

    switch (lastAction!.action) {
      case "create":
        // FIXME: Ustabilt
        //   await Promise.all(
        //     lastAction.orderItemIds.map((itemId: RecordIdString) => {
        //       pb.collection(Collections.OrderItem).delete(itemId);
        //     })
        //   );
        //   await pb.collection(Collections.Order).delete(lastAction.orderId);
        break;
      case "updateState":
        pb.collection(Collections.Order).update(lastAction!.orderId, {
          state: lastAction!.previousState
        });
        break;
    }
  }
};

const attachCustomizationsToOrderItem = async (
  orderItemId: RecordIdString,
  customizations: CustomizationValue[]
) => {
  const itemCustomizationIds = await createCustomizations(
    _.groupBy(customizations, (customization) => customization.belongsTo)
  );

  if (!_.isEmpty(itemCustomizationIds)) {
    await pb.collection(Collections.OrderItem).update(orderItemId, {
      customization: itemCustomizationIds
    });
  }
};

const createCustomizations = async (customizationsByKey: Record<string, CustomizationValue[]>) => {
  const entries = Object.entries(customizationsByKey);

  return Promise.all(
    entries.map(async ([keyId, values]) => {
      try {
        const valueIds = _.map(values, (v) => v.id);
        return createCustomization(keyId, valueIds);
      } catch (error) {
        console.error("Error creating item customization:", error);
        throw error;
      }
    })
  );
};

const createCustomization = async (
  keyId: string,
  valueIds: RecordIdString[]
): Promise<RecordIdString> => {
  const response = await pb.collection(Collections.ItemCustomization).create({
    key: keyId,
    value: valueIds
  });

  return response.id;
};

export const userOrders = createGenericPbStore(Collections.Order, Order, {
  ...baseOptions,
  filter: `customer = '${get(auth).user.id}'`
});
