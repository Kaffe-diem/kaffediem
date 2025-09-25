/**
 * This module is the only store that does not map to a PocketBase collection,
 * making the naming slightly misleading, even though it is a proper Svelte store.
 * TODO: Rename to reflect its purpose more clearly.
 */

import { writable, derived, get } from "svelte/store";
import type { Item, CustomizationValue, CustomizationKey } from "$lib/types";
import {
  customizationKeys,
  customizationValues,
  itemsByCategory,
  categories,
  getCategoryById
} from "./menuStore";
import { sumBy, groupBy, updateAt } from "$lib/utils";
import { finalPrice } from "$lib/pricing";

export interface CartItem extends Item {
  customizations: CustomizationValue[];
  basePrice: number;
}

// export const selectedItem = writable(get(itemsByCategory)[get(categories)[0].id][0]);
export const selectedItem = writable<Item | undefined>(undefined);
export const selectedCategory = derived(selectedItem, ($selectedItem) =>
  $selectedItem ? getCategoryById($selectedItem?.category) : undefined
);

export const selectedCustomizations = writable<Record<string, CustomizationValue[]>>({});
export const selectedCustomizationsFlat = derived(
  selectedCustomizations,
  ($selectedCustomizations) => Object.values($selectedCustomizations).flat()
);

export const cart = writable<CartItem[]>([]);

export const totalPrice = derived(cart, ($cart) => sumBy($cart, (item) => item.price));

export const editingIndex = writable<number | null>(null);

const repriceItem = (item: CartItem): CartItem => {
  const base = item.basePrice;
  const price = finalPrice(base, get(selectedCustomizationsFlat));
  return { ...item, basePrice: base, price } as CartItem;
};

const hydrateSelectedFromItem = (item: CartItem) => {
  const grouped = groupBy(
    (item.customizations || []).filter((v) => Boolean(v.belongsTo)),
    (v) => v.belongsTo as string
  );
  selectedCustomizations.set(grouped);
};

export const startEditing = (index: number) => {
  const current = get(cart)[index];
  if (!current) return;
  editingIndex.set(index);
  hydrateSelectedFromItem(current);
};

export const deleteEditingItem = () => {
  const index = get(editingIndex);
  if (index === null) return;
  removeFromCart(index);
  editingIndex.set(null);
  initializeCustomizations();
};

export const stopEditing = () => {
  editingIndex.set(null);
  initializeCustomizations();
};

const repriceEditingItemBySelections = () => {
  const index = get(editingIndex);
  if (index === null) return;
  cart.update((c) => updateAt(c, index, (item) => repriceItem(item)));
};

const validateCustomizations = () => {
  const category = get(categories).find((c) => c === get(selectedCategory));
  for (const key of get(customizationKeys)) {
    const isValid = category?.validCustomizations.includes(key.id);
    if (!isValid) {
      selectedCustomizations.update((c) => {
        c[key.id] = [];
        return c;
      });
    }
  }
};

export const applyDefaults = () => {
  const keys = get(customizationKeys);
  const values = get(customizationValues);
  const selected = get(selectedCustomizations);

  for (const key of keys) {
    const current = selected[key.id] ?? [];

    const defaultValue = values.find((val) => val.id === key.defaultValue)!;

    if (current.length === 0 && key.defaultValue && defaultValue.enabled) {
      selected[key.id] = [defaultValue];
    }
  }

  selectedCustomizations.set({ ...selected });
  validateCustomizations();
};

export const initializeCustomizations = () => {
  const map: Record<string, CustomizationValue[]> = {};
  selectedCustomizations.set(map);
  applyDefaults();
};

const updateSelectedCustomizations = (
  currentSelections: CustomizationValue[],
  value: CustomizationValue,
  multiple: boolean
) => {
  const alreadySelected = currentSelections?.some((v) => v.id === value.id);
  if (multiple)
    return alreadySelected
      ? currentSelections.filter((v) => v.id !== value.id)
      : [...currentSelections, value];
  return alreadySelected ? [] : [value];
};

export const toggleCustomization = (key: CustomizationKey, value: CustomizationValue) => {
  selectedCustomizations.update((map) => {
    const currentSelections = map[key.id] ?? [];
    const updatedSelections = updateSelectedCustomizations(
      currentSelections,
      value,
      key.multipleChoice
    );
    return { ...map, [key.id]: updatedSelections };
  });
  const index = get(editingIndex);
  if (index !== null) {
    cart.update((c) => {
      const item = c[index];
      if (!item) return c;

      const updatedItem: CartItem = {
        ...item,
        customizations: get(selectedCustomizationsFlat)
      } as CartItem;

      const newCart = [...c];
      newCart[index] = updatedItem!;
      return newCart;
    });
  }
  repriceEditingItemBySelections();
};

export const addToCart = (item: Item) => {
  const basePrice = item.price;
  const finalprice = finalPrice(basePrice, get(selectedCustomizationsFlat));

  const itemToAdd: CartItem = {
    ...item,
    price: Math.ceil(finalprice),
    customizations: get(selectedCustomizationsFlat),
    basePrice
  } as CartItem;

  cart.update((c) => [...c, itemToAdd]);
  initializeCustomizations();
};

export const removeFromCart = (index: number) => {
  cart.update((c) => c.filter((_, i) => i !== index));
};

export const clearCart = () => {
  cart.set([]);
  initializeCustomizations();
};
