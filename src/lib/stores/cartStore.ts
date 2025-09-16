/**
 * This module is the only store that does not map to a PocketBase collection,
 * making the naming slightly misleading, even though it is a proper Svelte store.
 * TODO: Rename to reflect its purpose more clearly.
 */

import { writable, derived, get } from "svelte/store";
import type { Item, CustomizationValue } from "$lib/types";

export interface CartItem extends Item {
  customizations: CustomizationValue[];
  basePrice?: number;
}

export const selectedCustomizations = writable<Record<string, CustomizationValue[]>>({});

export const cart = writable<CartItem[]>([]);

export const totalPrice = derived(cart, ($cart) =>
  $cart.reduce((sum, item) => sum + item.price, 0)
);

export const editingIndex = writable<number | null>(null);

const computeFinalPrice = (basePrice: number, customizations: CustomizationValue[]) => {
  const totalCustomizationPrice = customizations.reduce(
    (sum, customization) =>
      customization.constantPrice ? sum + (customization.priceChange || 0) : sum,
    0
  );

  const subtotal = basePrice + totalCustomizationPrice;
  const multiplied = customizations.reduce(
    (price, customization) =>
      !customization.constantPrice ? price * (customization.priceChange / 100) : price,
    subtotal
  );

  return multiplied;
};

const computeBasePriceFromFinal = (finalPrice: number, customizations: CustomizationValue[]) => {
  const totalCustomizationPrice = customizations.reduce(
    (sum, customization) =>
      customization.constantPrice ? sum + (customization.priceChange || 0) : sum,
    0
  );

  const multiplier = customizations.reduce(
    (acc, customization) =>
      !customization.constantPrice ? acc * (customization.priceChange / 100) : acc,
    1
  );

  const subtotal = multiplier ? finalPrice / multiplier : finalPrice;
  const base = subtotal - totalCustomizationPrice;
  return base;
};

const flattenCustomizations = (map: Record<string, CustomizationValue[]>) =>
  Object.values(map).flat();

const resolveBasePrice = (item: CartItem) =>
  item.basePrice ?? computeBasePriceFromFinal(item.price, item.customizations || []);

const repriceItem = (item: CartItem, customizations: CustomizationValue[]): CartItem => {
  const base = resolveBasePrice(item);
  const price = Math.ceil(computeFinalPrice(base, customizations));
  return { ...item, basePrice: base, customizations, price } as CartItem;
};

const hydrateSelectedFromItem = (item: CartItem) => {
  const map = (item.customizations || []).reduce(
    (acc, value) => {
      if (!value.belongsTo) return acc;
      (acc[value.belongsTo] ||= []).push(value);
      return acc;
    },
    {} as Record<string, CustomizationValue[]>
  );
  selectedCustomizations.set(map);
};

export const startEditing = (index: number) => {
  const current = get(cart)[index];
  if (!current) return;
  editingIndex.set(index);
  hydrateSelectedFromItem(current);
  if (current.basePrice == null) {
    cart.update((c) =>
      c.map((el, i) =>
        i === index
          ? Object.assign(Object.create(Object.getPrototypeOf(el)), {
              ...el,
              basePrice: resolveBasePrice(el)
            })
          : el
      )
    );
  }
};

export const deleteEditingItem = () => {
  const index = get(editingIndex);
  if (index === null) return;
  cart.update((c) => c.filter((_, i) => i !== index));
  editingIndex.set(null);
};

export const stopEditing = () => {
  editingIndex.set(null);
  initializeCustomizations();
};

const updateEditingItemFromSelections = (map: Record<string, CustomizationValue[]>) => {
  const index = get(editingIndex);
  if (index === null) return;
  const selected = flattenCustomizations(map);
  cart.update((c) => c.map((item, i) => (i === index ? repriceItem(item, selected) : item)));
};

export const initializeCustomizations = () => {
  const map: Record<string, CustomizationValue[]> = {};
  selectedCustomizations.set(map);
};

export const selectCustomization = (keyId: string, value: CustomizationValue) => {
  selectedCustomizations.update((customizations) => {
    const currentValues = customizations[keyId] || [];
    const valueIndex = currentValues.findIndex((v) => v.id === value.id);

    if (valueIndex > -1) {
      const updated = removeCustomizationValue(customizations, keyId, currentValues, valueIndex);
      updateEditingItemFromSelections(updated);
      return updated;
    } else {
      const updated = addCustomizationValue(customizations, keyId, value);
      updateEditingItemFromSelections(updated);
      return updated;
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

  const basePrice = item.price;
  const finalprice = computeFinalPrice(basePrice, customizations);

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
