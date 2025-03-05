import { createGenericPbStore, createPbStore } from "$stores/pbStore";
import pb, { Collections, type RecordIdString } from "$lib/pocketbase";
import { State, Order, CustomizationValue } from "$lib/types";
import auth from "$stores/authStore";
import { get } from "svelte/store";

const today = new Date().toISOString().split("T")[0];

const baseOptions = {
  expand: [
    "items",
    "items.item",
    "items.customization",
    "items.customization.key",
    "items.customization.value"
  ].join(","),
  filter: `created >= "${today}"`,
  sort: "-created"
};

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
        
        if (customizations.length > 0) {
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

const attachCustomizationsToOrderItem = async (orderItemId: RecordIdString, customizations: CustomizationValue[]) => {
  const customizationsByKey = groupCustomizationsByKey(customizations);
  const itemCustomizationIds = await createItemCustomizations(customizationsByKey);
  
  if (itemCustomizationIds.length > 0) {
    await pb.collection(Collections.OrderItem).update(orderItemId, {
      customization: itemCustomizationIds
    });
    
    await verifyCustomizationsAttached(orderItemId);
  }
};

const groupCustomizationsByKey = (customizations: CustomizationValue[]) => {
  const groupedCustomizations: Record<string, CustomizationValue[]> = {};
  
  customizations.forEach(customization => {
    const keyId = customization.belongsTo;
    if (!keyId) return;
    
    if (!groupedCustomizations[keyId]) {
      groupedCustomizations[keyId] = [];
    }
    
    groupedCustomizations[keyId].push(customization);
  });
  
  return groupedCustomizations;
};

const createItemCustomizations = async (customizationsByKey: Record<string, CustomizationValue[]>) => {
  return Promise.all(
    Object.entries(customizationsByKey).map(async ([keyId, values]) => {
      try {
        const valueIds = values.map(v => v.id);
        const existingCustomizations = await pb.collection(Collections.ItemCustomization).getList(1, 1, {
          filter: `key = "${keyId}" && value ~ "${valueIds.join('"||value ~ "')}"`
        });
        
        for (const existing of existingCustomizations.items) {
          const existingValueIds = existing.value || [];
          if (existingValueIds.length === valueIds.length && 
              valueIds.every(id => existingValueIds.includes(id))) {
            return existing.id;
          }
        }
        
        // If no exact match, create a new customization
        const response = await pb.collection(Collections.ItemCustomization).create({
          key: keyId,
          value: values.map(v => v.id)
        });
        
        return response.id;
      } catch (error) {
        console.error("Error creating item customization:", error);
        throw error;
      }
    })
  );
};

const verifyCustomizationsAttached = async (orderItemId: RecordIdString) => {
  const updatedOrderItem = await pb.collection(Collections.OrderItem).getOne(orderItemId, {
    expand: "customization"
  });
  
  if (!updatedOrderItem.customization || updatedOrderItem.customization.length === 0) {
    console.error("Failed to update order item with customizations", updatedOrderItem);
  }
};

export const userOrders = createGenericPbStore(Collections.Order, Order, {
  ...baseOptions,
  filter: `customer = '${get(auth).user.id}'`
});
