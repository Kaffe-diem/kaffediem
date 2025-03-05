import { createGenericPbStore, createPbStore } from "$stores/pbStore";
import pb, { Collections, type RecordIdString } from "$lib/pocketbase";
import { State, Order, CustomizationValue } from "$lib/types";
import auth from "$stores/authStore";
import { get } from "svelte/store";

const today = new Date().toISOString().split("T")[0];

const baseOptions = {
  expand: "items,items.item,items.customization,items.customization.key,items.customization.value",
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
    const getOrderItemIds = async (): Promise<RecordIdString[]> => {
      return await Promise.all(
        items.map(async ({ itemId, customizations }) => {
          // First create the order item
          const orderItemResponse = await pb.collection(Collections.OrderItem).create({ 
            item: itemId 
          });
          
          // Then create item_customization records for each customization value
          // and link them to the order item
          if (customizations.length > 0) {
            // Group customizations by key
            const customizationsByKey: Record<string, CustomizationValue[]> = {};
            
            customizations.forEach(customization => {
              const keyId = customization.belongsTo;
              if (!keyId) return;
              
              if (!customizationsByKey[keyId]) {
                customizationsByKey[keyId] = [];
              }
              
              customizationsByKey[keyId].push(customization);
            });
            
            // Create an item_customization for each key with its values
            const itemCustomizationIds = await Promise.all(
              Object.entries(customizationsByKey).map(async ([keyId, values]) => {
                const itemCustomizationResponse = await pb.collection(Collections.ItemCustomization).create({
                  key: keyId,
                  value: values.map(v => v.id)
                });
                
                return itemCustomizationResponse.id;
              })
            );
            
            // Link the item_customization records to the order_item
            if (itemCustomizationIds.length > 0) {
              await pb.collection(Collections.OrderItem).update(orderItemResponse.id, {
                customization: itemCustomizationIds
              });
              
              // Verify that the update was successful
              const updatedOrderItem = await pb.collection(Collections.OrderItem).getOne(orderItemResponse.id, {
                expand: "customization"
              });
              
              if (!updatedOrderItem.customization || updatedOrderItem.customization.length === 0) {
                console.error("Failed to update order item with customizations", updatedOrderItem);
              }
            }
          }
          
          return orderItemResponse.id;
        })
      );
    };

    await pb.collection(Collections.Order).create({
      customer: userId,
      items: await getOrderItemIds(),
      state: State.received,
      payment_fulfilled: false
    });
  },

  updateState: (orderId: RecordIdString, state: State) => {
    pb.collection(Collections.Order).update(orderId, { state });
  }
};

export const userOrders = createGenericPbStore(Collections.Order, Order, {
  ...baseOptions,
  filter: `customer = '${get(auth).user.id}'`
});
