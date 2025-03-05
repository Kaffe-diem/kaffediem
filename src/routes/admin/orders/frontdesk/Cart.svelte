<script lang="ts">
  import { addToCart, cart, clearCart, type CartItem } from "$stores/cartStore";
  import auth from "$stores/authStore";
  import orderStore from "$stores/orderStore";
  import CustomizationSelection from "./CustomizationSelection.svelte";
  import CartDisplay from "./CartDisplay.svelte";
  import { type Item } from "$lib/types";
  
  let { selectedItem } = $props<{ selectedItem: Item | null }>();
  let customizationSelection: CustomizationSelection;

  function handleAddToCart() {
    if (!selectedItem) return;
    
    const customizations = customizationSelection.getSelectedCustomizationsForItem();
    
    addToCart(selectedItem, customizations);
  }

  function completeOrder() {
    orderStore.create(
      $auth.user.id,
      $cart.map((item: CartItem) => item.id)
    );
    
    clearCart();
  }
</script>

<div class="flex h-full flex-col justify-between gap-4">
  <CustomizationSelection bind:this={customizationSelection} {selectedItem} />
  
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