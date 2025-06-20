/**
 * This module is the only store that does not map to a PocketBase collection,
 * making the naming slightly misleading, even though it is a proper Svelte store.
 * TODO: Rename to reflect its purpose more clearly.
 */

import { writable, derived, get } from "svelte/store";
import type { Item, CustomizationValue } from "$lib/types";

export interface CartItem extends Item {
  customizations: CustomizationValue[];
}

export const selectedCustomizations = writable<Record<string, CustomizationValue[]>>({});

export const cart = writable<CartItem[]>([]);

export const totalPrice = derived(cart, ($cart) =>
  $cart.reduce((sum, item) => sum + item.price, 0)
);

export const initializeCustomizations = () => {
  const map: Record<string, CustomizationValue[]> = {};
  selectedCustomizations.set(map);
};

export const selectCustomization = (keyId: string, value: CustomizationValue) => {
  selectedCustomizations.update((customizations) => {
    const currentValues = customizations[keyId] || [];
    const valueIndex = currentValues.findIndex((v) => v.id === value.id);

    if (valueIndex > -1) {
      return removeCustomizationValue(customizations, keyId, currentValues, valueIndex);
    } else {
      return addCustomizationValue(customizations, keyId, value);
    }
  });
};

const removeCustomizationValue = (
  customizations: Record<string, CustomizationValue[]>,
  keyId: string,
  currentValues: CustomizationValue[],
  valueIndex: number
): Record<string, CustomizationValue[]> => {
  const newValues = [...currentValues];
  newValues.splice(valueIndex, 1);

  if (newValues.length === 0) {
    // If no values left, remove the key
    // eslint-disable-next-line @typescript-eslint/no-unused-vars
    const { [keyId]: _, ...rest } = customizations;
    return rest;
  }

  return {
    ...customizations,
    [keyId]: newValues
  };
};

const addCustomizationValue = (
  customizations: Record<string, CustomizationValue[]>,
  keyId: string,
  value: CustomizationValue
): Record<string, CustomizationValue[]> => {
  return {
    ...customizations,
    [keyId]: [...(customizations[keyId] || []), value]
  };
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
