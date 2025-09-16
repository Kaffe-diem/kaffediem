/**
 * This module is the only store that does not map to a PocketBase collection,
 * making the naming slightly misleading, even though it is a proper Svelte store.
 * TODO: Rename to reflect its purpose more clearly.
 */

import { writable, derived, get } from "svelte/store";
import type { Item, CustomizationValue } from "$lib/types";
import { sumBy, productBy, groupBy, assoc, updateAt } from "$lib/utils";

export interface CartItem extends Item {
  customizations: CustomizationValue[];
  basePrice?: number;
}

export const selectedCustomizations = writable<Record<string, CustomizationValue[]>>({});

export const cart = writable<CartItem[]>([]);

export const totalPrice = derived(cart, ($cart) => sumBy($cart, (item) => item.price));

export const editingIndex = writable<number | null>(null);

const computeFinalPrice = (basePrice: number, customizations: CustomizationValue[]) => {
  const totalCustomizationPrice = sumBy(
    customizations,
    (c) => (c.constantPrice ? c.priceChange || 0 : 0)
  );

  const subtotal = basePrice + totalCustomizationPrice;
  const factor = productBy(customizations, (c) => (!c.constantPrice ? c.priceChange / 100 : 1));
  return subtotal * factor;
};

const computeBasePriceFromFinal = (finalPrice: number, customizations: CustomizationValue[]) => {
  const totalCustomizationPrice = sumBy(
    customizations,
    (c) => (c.constantPrice ? c.priceChange || 0 : 0)
  );

  const multiplier = productBy(customizations, (c) => (!c.constantPrice ? c.priceChange / 100 : 1));
  const subtotal = multiplier ? finalPrice / multiplier : finalPrice;
  return subtotal - totalCustomizationPrice;
};

const resolveBasePrice = (item: CartItem) =>
  item.basePrice ?? computeBasePriceFromFinal(item.price, item.customizations || []);

const ensureBasePrice = (item: CartItem): CartItem =>
  assoc(item, "basePrice", resolveBasePrice(item));

const repriceItem = (item: CartItem, customizations: CustomizationValue[]): CartItem => {
  const base = resolveBasePrice(item);
  const price = Math.ceil(computeFinalPrice(base, customizations));
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
  if (current.basePrice == null) {
    cart.update((c) => {
      const updated = updateAt(c, index, ensureBasePrice);
      return updated;
    });
  }
};

export const deleteEditingItem = () => {
  const index = get(editingIndex);
  if (index === null) return;
  removeFromCart(index);
  editingIndex.set(null);
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

export const initializeCustomizations = () => {
  const map: Record<string, CustomizationValue[]> = {};
  selectedCustomizations.set(map);
};

export const selectCustomization = (keyId: string, value: CustomizationValue) => {
  selectedCustomizations.update((customizations) => {
    const currentValues = customizations[keyId] || [];
    const valueIndex = currentValues.findIndex((v) => v.id === value.id);

    const updated =
      valueIndex > -1
        ? removeCustomizationValue(customizations, keyId, currentValues, valueIndex)
        : addCustomizationValue(customizations, keyId, value);
    repriceEditingItemBySelections(updated);
    return updated;
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
