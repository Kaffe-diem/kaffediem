/**
 * This module is the only store which is not mapping to a pocketbase collection,
 * therefore the naming is misleading, even if it still a proper svelte store.
 * todo: name convention change.
 */

import { writable, derived } from 'svelte/store';
import type { Item, CustomizationValue } from '$lib/types';

export interface CartItem extends Item {
  customizations: CustomizationValue[];
}

export const selectedCustomizations = writable<Record<string, string>>({});

export const cart = writable<CartItem[]>([]);

export const totalPrice = derived(cart, ($cart) => 
  $cart.reduce((sum, item) => sum + item.price, 0)
);

export function resetCustomizations() {
  selectedCustomizations.set({});
}

export function selectCustomization(keyId: string, valueId: string) {
  selectedCustomizations.update(current => ({
    ...current,
    [keyId]: valueId
  }));
}

export function addToCart(item: Item, customizations: CustomizationValue[]) {
  const totalCustomizationPrice = customizations.reduce(
    (sum, customization) => sum + (customization.priceIncrementNok || 0), 
    0
  );
  
  const itemToAdd = {
    ...item,
    price: item.price + totalCustomizationPrice,
    customizations: customizations
  } as CartItem;
  
  cart.update(current => [...current, itemToAdd]);
  
  resetCustomizations();
}

export function removeFromCart(index: number) {
  cart.update(current => {
    current.splice(index, 1);
    return current;
  });
}

export function clearCart() {
  cart.set([]);
} 