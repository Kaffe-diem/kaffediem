import { writable, derived } from 'svelte/store';
import type { Item, CustomizationValue } from '$lib/types';

// Define a type for cart items that includes customizations
export interface CartItem extends Item {
  customizations: CustomizationValue[];
}

// Create a store for selected customizations
export const selectedCustomizations = writable<Record<string, string>>({});

// Create a cart store
export const cart = writable<CartItem[]>([]);

// Derived store for total price
export const totalPrice = derived(cart, ($cart) => 
  $cart.reduce((sum, item) => sum + item.price, 0)
);

// Reset customization selections
export function resetCustomizations() {
  selectedCustomizations.set({});
}

// Add selection to customizations
export function selectCustomization(keyId: string, valueId: string) {
  selectedCustomizations.update(current => ({
    ...current,
    [keyId]: valueId
  }));
}

// Add item to cart with selected customizations
export function addToCart(item: Item, customizations: CustomizationValue[]) {
  // Calculate total customization price
  const totalCustomizationPrice = customizations.reduce(
    (sum, customization) => sum + (customization.priceIncrementNok || 0), 
    0
  );
  
  // Create a new item with the updated price
  const itemToAdd = {
    ...item,
    price: item.price + totalCustomizationPrice,
    customizations: customizations
  } as CartItem;
  
  // Add to cart
  cart.update(current => [...current, itemToAdd]);
  
  // Reset selections after adding to cart
  resetCustomizations();
}

// Remove item from cart
export function removeFromCart(index: number) {
  cart.update(current => {
    current.splice(index, 1);
    return current;
  });
}

// Clear cart
export function clearCart() {
  cart.set([]);
} 