<script lang="ts">
  import { addToCart, cart, clearCart, type CartItem } from "$stores/cartStore";
  import auth from "$stores/authStore";
  import orderStore from "$stores/orderStore";
  import CustomizationSelection from "./CustomizationSelection.svelte";
  import CartDisplay from "./CartDisplay.svelte";
  import { type Item } from "$lib/types";
  
  // Define the component prop
  export let selectedItem: Item | null = null;
  
  // Reference to the CustomizationSelection component
  let customizationSelection: CustomizationSelection;

  // Add the current item to cart with selected customizations
  function handleAddToCart() {
    if (!selectedItem) return;
    
    // Get selected customization values from the component
    const customizations = customizationSelection.getSelectedCustomizationsForItem();
    
    // Add to cart using the store function
    addToCart(selectedItem, customizations);
  }

  // Complete order function
  function completeOrder() {
    // Create order using orderStore
    orderStore.create(
      $auth.user.id,
      $cart.map((item: CartItem) => item.id)
    );
    
    // Clear the cart after order is created
    clearCart();
  }
</script>

<div class="flex h-full flex-col justify-between gap-4">
  <!-- Customization Selection Component -->
  <CustomizationSelection bind:this={customizationSelection} {selectedItem} />
  
  <!-- Cart Display Component -->
  <CartDisplay />
  
  <div class="flex flex-row justify-center gap-2">
    <button
      class="bold btn btn-lg text-xl"
      onclick={completeOrder}>Ferdig</button
    >
    <button
      class="bold btn btn-primary btn-lg text-3xl"
      onclick={handleAddToCart}>+</button
    >
  </div>
</div>