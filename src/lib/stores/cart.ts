/**
 * This module is the only store that does not map to a database table,
 * making the naming slightly misleading, even though it is a proper Svelte store.
 * TODO: Rename to reflect its purpose more clearly.
 */

import { writable, derived, get } from "svelte/store";
import type { Item, CustomizationValue, CustomizationKey } from "$lib/types";
import { menuIndexes } from "./menu";
import { sumBy, groupBy, updateAt } from "$lib/utils";
import { finalPrice } from "$lib/pricing";

export interface CartItem extends Item {
  customizations: CustomizationValue[];
  basePrice: number;
  totalPrice: number;
}

export const selectedItemId = writable<string | undefined>(undefined);
const indexes = menuIndexes;

export const selectedItem = derived([selectedItemId, indexes], ([$selectedItemId, $indexes]) =>
  $indexes.items.find((item) => item.id === $selectedItemId)
);

export const selectedCategory = derived([selectedItem, indexes], ([$selectedItem, $indexes]) =>
  $selectedItem
    ? $indexes.categories.find((category) => category.id === $selectedItem.category)
    : undefined
);

export const selectedCustomizations = writable<Record<string, CustomizationValue[]>>({});
export const selectedCustomizationsFlat = derived(
  selectedCustomizations,
  ($selectedCustomizations) => Object.values($selectedCustomizations).flat()
);

export const cart = writable<CartItem[]>([]);

export const totalPrice = derived(cart, ($cart) => sumBy($cart, (item) => item.totalPrice));

export const editingIndex = writable<number | null>(null);

const repriceItem = (item: CartItem): CartItem => {
  const base = item.basePrice;
  const price = finalPrice(base, get(selectedCustomizationsFlat));
  return { ...item, basePrice: base, totalPrice: price } as CartItem;
};

const hydrateSelectedFromItem = (item: CartItem) => {
  const grouped = groupBy(
    (item.customizations || []).filter((v) => Boolean(v.belongs_to)),
    (v) => v.belongs_to as string
  );
  selectedCustomizations.set(grouped);
};

export const startEditing = (index: number) => {
  const current = get(cart)[index];
  if (!current) return;
  editingIndex.set(index);
  hydrateSelectedFromItem(current);
  selectedItemId.set(current.id);
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
  const category = get(selectedCategory);
  const { customization_keys: keys } = get(indexes);
  const valid = new Set(category?.valid_customizations ?? []);

  for (const key of keys) {
    const isValid = valid.has(key.id);
    if (!isValid) {
      selectedCustomizations.update((c) => {
        c[key.id] = [];
        return c;
      });
    }
  }
};

export const applyDefaults = () => {
  const { customization_keys: keys, customization_values: values } = get(indexes);
  const selected = get(selectedCustomizations);

  for (const key of keys) {
    const current = selected[key.id] ?? [];
    const defaultValue = values.find((val) => val.id === key.default_value);

    if (current.length === 0 && key.default_value && defaultValue?.enable) {
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
      key.multiple_choice
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

export const handleSelectedItemChange = () => {
  applyDefaults();
  const index = get(editingIndex);
  if (index !== null) {
    cart.update((c) => {
      const item = get(selectedItem)!;

      const updatedItem = buildCartItem(item, get(selectedCustomizationsFlat));

      const newCart = [...c];
      newCart[index] = updatedItem!;
      return newCart;
    });
  }
};

export const addToCart = (item: Item) => {
  cart.update((c) => [...c, buildCartItem(item, get(selectedCustomizationsFlat))]);
  initializeCustomizations();
};

export const removeFromCart = (index: number) => {
  cart.update((c) => c.filter((_, i) => i !== index));
};

const buildCartItem = (item: Item, customizations: CustomizationValue[]): CartItem => {
  const basePrice = item.price_nok;
  const totalPrice = Math.ceil(finalPrice(basePrice, customizations));
  return {
    ...item,
    totalPrice,
    basePrice,
    customizations
  } as CartItem;
};

export const clearCart = () => {
  cart.set([]);
  initializeCustomizations();
};
