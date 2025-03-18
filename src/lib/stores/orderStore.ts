import { createGenericPbStore, createPbStore } from "$stores/pbStore";
import pb, { Collections, type RecordIdString } from "$lib/pocketbase";
import { State, Order, CustomizationValue } from "$lib/types";
import auth from "$stores/authStore";
import { get } from "svelte/store";
import * as R from "remeda";

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

// this is very similar to CartItem from CartStore
// todo: address issue simultaneously
export interface OrderItemWithCustomizations {
  itemId: RecordIdString;
  customizations: CustomizationValue[];
}

export default {
  subscribe: createPbStore(Collections.Order, Order, baseOptions),

  create: async (userId: RecordIdString, items: OrderItemWithCustomizations[]) => {
    const orderItemIds = await Promise.all(
      items.map(async ({ itemId, customizations }) => {
        const orderItemResponse = await pb.collection(Collections.OrderItem).create({
          item: itemId
        });

        if (!R.isEmpty(customizations)) {
          await attachCustomizationsToOrderItem(orderItemResponse.id, customizations);
        }

        return orderItemResponse.id;
      })
    );

    await pb.collection(Collections.Order).create({
      customer: userId,
      items: orderItemIds,
      state: State.received,
      payment_fulfilled: false
    });
  },

  updateState: (orderId: RecordIdString, state: State) => {
    pb.collection(Collections.Order).update(orderId, { state });
  }
};

const attachCustomizationsToOrderItem = async (
  orderItemId: RecordIdString,
  customizations: CustomizationValue[]
) => {
  const itemCustomizationIds = await createItemCustomizations(
    R.groupBy(customizations, (customization) => customization.belongsTo)
  );

  if (!R.isEmpty(itemCustomizationIds)) {
    await pb.collection(Collections.OrderItem).update(orderItemId, {
      customization: itemCustomizationIds
    });
  }
};

const createItemCustomizations = async (
  customizationsByKey: Record<string, CustomizationValue[]>
) => {
  const entries = Object.entries(customizationsByKey);

  return Promise.all(
    entries.map(async ([keyId, values]) => {
      try {
        const valueIds = R.map(values, (v) => v.id);
        const existingId = await findExistingCustomization(keyId, valueIds);

        return existingId ? existingId : createNewCustomization(keyId, valueIds);
      } catch (error) {
        console.error("Error creating item customization:", error);
        throw error;
      }
    })
  );
};

const findExistingCustomization = async (
  keyId: string,
  valueIds: RecordIdString[]
): Promise<RecordIdString | null> => {
  const existingCustomizations = await pb.collection(Collections.ItemCustomization).getList(1, 1, {
    // key is key and value is one of valueIds
    filter: `key = "${keyId}" && value ~ "${valueIds.join('"||value ~ "')}"`
  });

  const match = R.find(existingCustomizations.items, (existing) =>
    isExactValueMatch(existing.value || [], valueIds)
  );

  return match ? match.id : null;
};

const isExactValueMatch = (
  existingValueIds: RecordIdString[],
  valueIds: RecordIdString[]
): boolean =>
  existingValueIds.length === valueIds.length &&
  R.intersection(existingValueIds, valueIds).length === valueIds.length;

const createNewCustomization = async (
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
