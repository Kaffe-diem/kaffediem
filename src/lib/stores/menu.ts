import { derived, get, writable } from "svelte/store";
import { getSocket } from "$lib/realtime/socket";
import { apiPost, apiPatch, apiDelete } from "./collection";
import {
  categoryFromApi,
  categoryToApi,
  itemFromApi,
  itemToApi,
  customizationKeyFromApi,
  customizationKeyToApi,
  customizationValueFromApi,
  customizationValueToApi,
  type Category,
  type Item,
  type CustomizationKey,
  type CustomizationValue
} from "$lib/types";

// Writable stores for menu data
export const categories = writable<Category[]>([]);
export const items = writable<Item[]>([]);
export const customizationKeys = writable<CustomizationKey[]>([]);
export const customizationValues = writable<CustomizationValue[]>([]);

// Subscribe to semantic menu channel
let channel: any | null = null;
const socket = getSocket();

if (socket) {
  channel = socket.channel("collection:menu", {});

  channel
    .join()
    .receive("ok", (payload: any) => {
      parseMenuData(payload?.items || []);
    })
    .receive("error", (error: unknown) => {
      console.error("Failed to join menu channel:", error);
      categories.set([]);
      items.set([]);
      customizationKeys.set([]);
      customizationValues.set([]);
    });

  channel.on("change", (event: any) => {
    // Menu changed - reload everything
    if (event?.action === "reload") {
      // Backend will send full menu on next join, or we can fetch
      // For now, the individual collection broadcasts still work
    }
  });
}

// Parse nested menu structure into flat stores
function parseMenuData(menuCategories: any[]) {
  const allCategories: Category[] = [];
  const allItems: Item[] = [];
  const allKeys: CustomizationKey[] = [];
  const allValues: CustomizationValue[] = [];
  const seenKeys = new Set<string>();
  const seenValues = new Set<string>();

  for (const cat of menuCategories) {
    // Parse category
    allCategories.push(categoryFromApi(cat));

    // Parse items in this category
    for (const item of cat.items || []) {
      // Extract customizations before parsing item
      const customizations = item.customizations || [];

      // Parse item (without customizations field)
      const { customizations: _, ...itemWithoutCustomizations } = item;
      allItems.push(itemFromApi(itemWithoutCustomizations));

      // Parse customization keys and values
      for (const cust of customizations) {
        if (cust.key && !seenKeys.has(cust.key.id)) {
          allKeys.push(customizationKeyFromApi(cust.key));
          seenKeys.add(cust.key.id);
        }

        for (const val of cust.values || []) {
          if (!seenValues.has(val.id)) {
            allValues.push(customizationValueFromApi(val));
            seenValues.add(val.id);
          }
        }
      }
    }
  }

  categories.set(allCategories);
  items.set(allItems);
  customizationKeys.set(allKeys);
  customizationValues.set(allValues);
}

// Derived stores - group items by category
export const itemsByCategory = derived(items, ($items) =>
  $items.reduce((acc: Record<string, Item[]>, item) => {
    acc[item.category] ||= [];
    acc[item.category]!.push(item);
    return acc;
  }, {})
);

// Derived store - group customization values by key
export const customizationsByKey = derived(customizationValues, ($values) =>
  $values.reduce((acc: Record<string, CustomizationValue[]>, val) => {
    acc[val.belongsTo] ||= [];
    acc[val.belongsTo]!.push(val);
    return acc;
  }, {})
);

// Helper
export function getCategoryById(id: string): Category | undefined {
  return get(categories).find((c) => c.id === id);
}

// CRUD operations
export async function createCategory(cat: Category): Promise<void> {
  await apiPost("category", categoryToApi(cat));
}

export async function updateCategory(cat: Category): Promise<void> {
  await apiPatch("category", cat.id, categoryToApi(cat));
}

export async function deleteCategory(id: string): Promise<void> {
  await apiDelete("category", id);
}

export async function createItem(item: Item): Promise<void> {
  await apiPost("item", itemToApi(item));
}

export async function updateItem(item: Item): Promise<void> {
  await apiPatch("item", item.id, itemToApi(item));
}

export async function deleteItem(id: string): Promise<void> {
  await apiDelete("item", id);
}

export async function createCustomizationKey(key: CustomizationKey): Promise<void> {
  await apiPost("customization_key", customizationKeyToApi(key));
}

export async function updateCustomizationKey(key: CustomizationKey): Promise<void> {
  await apiPatch("customization_key", key.id, customizationKeyToApi(key));
}

export async function deleteCustomizationKey(id: string): Promise<void> {
  await apiDelete("customization_key", id);
}

export async function createCustomizationValue(val: CustomizationValue): Promise<void> {
  await apiPost("customization_value", customizationValueToApi(val));
}

export async function updateCustomizationValue(val: CustomizationValue): Promise<void> {
  await apiPatch("customization_value", val.id, customizationValueToApi(val));
}

export async function deleteCustomizationValue(id: string): Promise<void> {
  await apiDelete("customization_value", id);
}

// Cleanup on module unload
export function destroyMenuChannel() {
  if (channel) {
    channel.leave();
    channel = null;
  }
}
