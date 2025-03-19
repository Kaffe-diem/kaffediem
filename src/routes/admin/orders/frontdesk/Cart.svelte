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
  import orderStore, { type OrderItemWithCustomizations } from "$stores/orderStore";
  import { customizationKeys } from "$stores/menuStore";
  import { type Item, type CustomizationValue } from "$lib/types";

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

  function completeOrder() {
    const orderItems: OrderItemWithCustomizations[] = $cart.map((item: CartItem) => {
      return {
        itemId: item.id,
        customizations: item.customizations
      };
    });

    orderStore.create($auth.user.id, orderItems);
    clearCart();
  }
</script>

<div class="flex flex-col justify-between gap-4">
  {@render CartDisplay()}

  <div class="flex flex-row justify-center gap-2">
    <button class="bold btn btn-lg text-xl" onclick={completeOrder}>Ferdig</button>
    <button class="bold btn btn-primary btn-lg text-3xl" onclick={handleAddToCart}>+</button>
  </div>
</div>

{#snippet CartDisplay()}
  <div class="overflow-y-auto">
    <table class="table table-pin-rows table-auto list-none shadow-2xl">
      <thead>
        <tr>
          <th class="w-full">Produkt</th>
          <th class="whitespace-nowrap">Pris</th>
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
    class="badge badge-sm"
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
      <th><span class="text-bold text-lg text-primary">{$totalPrice},-</span></th>
    </tr>
  </tfoot>
{/snippet}
