/**
 * This module is the only store that does not map to a PocketBase collection,
 * making the naming slightly misleading, even though it is a proper Svelte store.
 * TODO: Rename to reflect its purpose more clearly.
 */

import { writable, derived, get } from "svelte/store";
import type { Item, CustomizationValue, CustomizationKey } from "$lib/types";
import { customizationKeys, customizationValues } from "./menuStore";
import { sumBy, groupBy, updateAt } from "$lib/utils";
import { finalPrice } from "$lib/pricing";

export interface CartItem extends Item {
  customizations: CustomizationValue[];
  basePrice: number;
}

export const selectedCustomizations = writable<Record<string, CustomizationValue[]>>({});

export const cart = writable<CartItem[]>([]);

export const totalPrice = derived(cart, ($cart) => sumBy($cart, (item) => item.price));

export const editingIndex = writable<number | null>(null);

const repriceItem = (item: CartItem, customizations: CustomizationValue[]): CartItem => {
  const base = item.basePrice;
  const price = finalPrice(base, customizations);
  return { ...item, basePrice: base, customizations, price } as CartItem;
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

const repriceEditingItemBySelections = (map: Record<string, CustomizationValue[]>) => {
  const index = get(editingIndex);
  if (index === null) return;
  const selected = Object.values(map).flat();
  cart.update((c) => updateAt(c, index, (item) => repriceItem(item, selected)));
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

      const customizations = Object.values(get(selectedCustomizations)).flat();
      const updatedItem: CartItem = { ...item, customizations: customizations } as CartItem;

      let newCart = [...c];
      newCart[index] = updatedItem!;
      return newCart;
    });
  }
};

export const addToCart = (item: Item) => {
  // the initial selection maps to the categories of the customizations
  // so we just flatten this structure for the purposes of summation
  const customizations = Object.values(get(selectedCustomizations)).flat();

  const basePrice = item.price;
  const finalprice = finalPrice(basePrice, customizations);

  const itemToAdd: CartItem = {
    ...item,
    price: Math.ceil(finalprice),
    customizations,
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
