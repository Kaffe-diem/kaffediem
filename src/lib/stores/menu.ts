import { derived, get } from "svelte/store";
import { createCollection, apiPost, apiPatch, apiDelete } from "./collection";
import {
  categoryFromApi,
  categoryToApi,
  itemFromApi,
  itemToApi,
  customizationKeyFromApi,
  customizationKeyToApi,
  customizationValueFromApi,
  customizationValueToApi,
  itemCustomizationFromApi,
  itemCustomizationToApi,
  type Category,
  type Item,
  type CustomizationKey,
  type CustomizationValue,
  type ItemCustomization
} from "$lib/types";

// Collections
export const categories = createCollection("category", categoryFromApi);
export const items = createCollection("item", itemFromApi);
export const customizationKeys = createCollection("customization_key", customizationKeyFromApi);
export const customizationValues = createCollection("customization_value", customizationValueFromApi);
export const itemCustomizations = createCollection("item_customization", itemCustomizationFromApi);

// Derived store - group items by category
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

export async function createItemCustomization(ic: ItemCustomization): Promise<void> {
  await apiPost("item_customization", itemCustomizationToApi(ic));
}

export async function updateItemCustomization(ic: ItemCustomization): Promise<void> {
  await apiPatch("item_customization", ic.id, itemCustomizationToApi(ic));
}

export async function deleteItemCustomization(id: string): Promise<void> {
  await apiDelete("item_customization", id);
}
