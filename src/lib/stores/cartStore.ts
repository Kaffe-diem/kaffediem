/**
 * This module is the only store that does not map to a PocketBase collection,
 * making the naming slightly misleading, even though it is a proper Svelte store.
 * TODO: Rename to reflect its purpose more clearly.
 */

import { writable, derived, get } from "svelte/store";
import type { Item, CustomizationValue } from "$lib/types";
import { customizationKeys, customizationValues } from "./menuStore";

export interface CartItem extends Item {
  customizations: CustomizationValue[];
}

export const selectedCustomizations = writable<Record<string, CustomizationValue[]>>({});

export const cart = writable<CartItem[]>([]);

export const totalPrice = derived(cart, ($cart) =>
  $cart.reduce((sum, item) => sum + item.price, 0)
);

export const applyDefaults = () => {
  const keys = get(customizationKeys);
  const values = get(customizationValues);
  const selected = get(selectedCustomizations);

  for (const key of keys) {
    const current = selected[key.id] ?? [];

    if (current.length === 0 && key.defaultValue) {
      selected[key.id] = values.filter((val) => val.id === key.defaultValue);
    }
  }

  selectedCustomizations.set({ ...selected });
};

export const initializeCustomizations = () => {
  const map: Record<string, CustomizationValue[]> = {};
  selectedCustomizations.set(map);
  applyDefaults();
};

export const addToCart = (item: Item) => {
  // the initial selection maps to the categories of the customizations
  // so we just flatten this structure for the purposes of summation
  const customizations = Object.values(get(selectedCustomizations)).flat();

  const totalCustomizationPrice = customizations.reduce(
    (sum, customization) =>
      customization.constantPrice ? sum + (customization.priceChange || 0) : sum,
    0
  );

  const subtotal = item.price + totalCustomizationPrice;
  const finalprice = customizations.reduce(
    (price, customization) =>
      !customization.constantPrice ? price * (customization.priceChange / 100) : price,
    subtotal
  );

  const itemToAdd: CartItem = {
    ...item,
    price: Math.ceil(finalprice),
    customizations
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
