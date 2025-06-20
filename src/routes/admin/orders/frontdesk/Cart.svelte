<script lang="ts">
  import {
    addToCart,
    cart,
    clearCart,
    type CartItem,
    removeFromCart,
    totalPrice
  } from "$stores/cartStore";
  import auth from "$stores/authStore";
  import orderStore from "$stores/orderStore";
  import { customizationKeys } from "$stores/menuStore";
  import { type Item, type CustomizationValue } from "$lib/types";
  import orders from "$stores/orderStore";
  import CommentIcon from "$assets/CommentIcon.svelte";

  let { selectedItem } = $props<{
    selectedItem: Item | undefined;
  }>();

  const colors = $derived(
    Object.fromEntries($customizationKeys.map((key) => [key.id, key.labelColor]))
  );

  function handleAddToCart() {
    if (!selectedItem) return;
    addToCart(selectedItem);
  }

  let missing_information = $state(false);
  function completeOrder() {
    orderStore.create($auth.user.id, $cart, missing_information);
    clearCart();
    missing_information = false;
  }
</script>

<div class="flex flex-col justify-between gap-4">
  {@render CartDisplay()}

  <div class="flex flex-row justify-center gap-2">
    <label>
      <input type="checkbox" name="item" class="peer hidden" bind:checked={missing_information} />
      <div
        class="btn btn-lg {missing_information
          ? 'ring-lg ring-warning bg-warning shadow-xl ring'
          : ''} flex transition-all duration-300 ease-in-out hover:brightness-90 focus:outline-none"
      >
        <span class="text-3xl"><CommentIcon /></span>
      </div>
    </label>
    <button class="bold btn btn-lg text-xl" onclick={completeOrder}
      >Ferdig ({$orders.length + 100})</button
    >
    <button class="bold btn btn-primary btn-lg text-3xl" onclick={handleAddToCart}>+</button>
  </div>
</div>

{#snippet CartDisplay()}
  <div class="overflow-y-auto">
    <table class="table-pin-rows table table-auto list-none shadow-2xl">
      <thead class="sr-only">
        <tr>
          <th class="w-full">Produkt</th>
        </tr>
      </thead>
      <tbody>
        {#if $cart.length > 0}
          {#each $cart as item, index}
            {@render CartItem({ item, index })}
          {/each}
        {:else}
          {@render EmptyCartRow()}
        {/if}
      </tbody>
      {@render CartFooter()}
    </table>
  </div>
{/snippet}

{#snippet CustomizationBadge({ customization }: { customization: CustomizationValue })}
  <span
    class="badge badge-sm md:badge-md lg:badge-lg"
    style={customization.belongsTo && colors[customization.belongsTo]
      ? `background-color: ${colors[customization.belongsTo]}; color: white;`
      : ""}
  >
    {customization.name}
  </span>
{/snippet}

{#snippet CartItem({ item, index }: { item: CartItem; index: number })}
  <tr class="hover select-none" onclick={() => removeFromCart(index)}>
    <td>
      <div>
        <div>{item.name}</div>
        {#if item.customizations && item.customizations.length > 0}
          <div class="mt-1 flex flex-wrap gap-1">
            {#each item.customizations as customization}
              {#if customization.name}
                {@render CustomizationBadge({ customization })}
              {/if}
            {/each}
          </div>
        {/if}
      </div>
    </td>
    <td>{item.price},-</td>
  </tr>
{/snippet}

{#snippet EmptyCartRow()}
  <tr>
    <td>Ingenting</td>
    <td></td>
  </tr>
{/snippet}

{#snippet CartFooter()}
  <tfoot>
    <tr>
      <th>Total: <span class="text-neutral">{$cart.length}</span></th>
      <th><span class="text-bold text-primary text-lg">{$totalPrice},-</span></th>
    </tr>
  </tfoot>
{/snippet}
