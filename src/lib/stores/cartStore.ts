/**
 * This module is the only store that does not map to a PocketBase collection,
 * making the naming slightly misleading, even though it is a proper Svelte store.
 * TODO: Rename to reflect its purpose more clearly.
 */

import { writable, derived, get } from "svelte/store";
import type { Item, CustomizationValue } from "$lib/types";
import { customizationValues } from "./menuStore";

export interface CartItem extends Item {
  customizations: CustomizationValue[];
}

export const selectedCustomizations = writable<Record<string, string>>({});

export const cart = writable<CartItem[]>([]);

export const totalPrice = derived(cart, ($cart) =>
  $cart.reduce((sum, item) => sum + item.price, 0)
);

export const initializeCustomizations = () => {
  const map: Record<string, string> = {};
  const values = get(customizationValues);
  const defaultCustomizations = ["Hel", "Egen"];

  values.forEach((value) => {
    if (defaultCustomizations.includes(value.name)) {
      map[value.belongsTo] = value.id;
    }
  });

  selectedCustomizations.set(map);
};

export const selectCustomization = (keyId: string, valueId: string) => {
  selectedCustomizations.update((customizations) => ({
    ...customizations,
    [keyId]: valueId
  }));
};

export const addToCart = (item: Item, customizations: CustomizationValue[]) => {
  const totalCustomizationPrice = customizations.reduce(
    (sum, customization) => sum + (customization.priceIncrementNok || 0),
    0
  );

  const itemToAdd: CartItem = {
    ...item,
    price: item.price + totalCustomizationPrice,
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
