<script lang="ts">
  import {
    addToCart,
    cart,
    clearCart,
    type CartItem,
    totalPrice,
    editingIndex,
    startEditing,
    deleteEditingItem,
    stopEditing,
    selectedItem
  } from "$stores/cart";
  import auth from "$stores/auth";
  import { orders, createOrder } from "$stores/orders";
  import { customizationKeys } from "$stores/menu";
  import type { CustomizationValue } from "$lib/types";
  import CommentIcon from "$assets/CommentIcon.svelte";
  import CompleteOrder from "$assets/CompleteOrder.svelte";
  import TrashIcon from "$assets/TrashIcon.svelte";
  import { getCharacters } from "$lib/utils";

  const colors = $derived(
    Object.fromEntries($customizationKeys.map((key) => [key.id, key.labelColor]))
  );

  const handleAddToCart = () => {
    if ($editingIndex !== null) {
      stopEditing();
      return;
    }
    if (!selectedItem) return;
    addToCart($selectedItem!);
  };

  let missing_information = $state(false);
  async function completeOrder() {
    await createOrder($auth.user.id, $cart, missing_information);
    clearCart();
    missing_information = false;
    stopEditing();
  }
</script>

<div class="flex flex-col justify-between gap-4">
  {#if $cart.length > 0}
    {@render CartDisplay()}
  {/if}

  <div class="flex flex-row justify-center gap-2">
    <label class={$cart.length > 0 ? "" : "invisible"}>
      <input type="checkbox" name="item" class="peer hidden" bind:checked={missing_information} />
      <div
        class="btn btn-lg {missing_information
          ? 'ring-lg ring-warning bg-warning shadow-xl ring'
          : ''} flex hover:brightness-90 focus:outline-none"
      >
        <span class="text-2xl"><CommentIcon /></span>
      </div>
    </label>

    <button
      class="bold btn btn-lg {$cart.length > 0 ? '' : 'invisible'}"
      data-testid="complete-order-button"
      onclick={completeOrder}
    >
      <CompleteOrder />
    </button>

    <button class="bold btn btn-lg btn-primary text-3xl" onclick={handleAddToCart}
      >{$editingIndex !== null ? "OK" : "+"}</button
    >
  </div>
</div>

{#snippet CartDisplay()}
  <div class="overflow-y-auto {missing_information ? 'bg-warning' : ''}">
    <table class="table-pin-rows table table-auto list-none shadow-2xl">
      <thead class="sr-only">
        <tr>
          <th class="w-full">Produkt</th>
        </tr>
      </thead>
      <tbody>
        {#each $cart as item, index (index)}
          {@render CartItem({ item, index, showIndex: $cart.length > 1 })}
        {/each}
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

{#snippet CartItem({
  item,
  index,
  showIndex
}: {
  item: CartItem;
  index: number;
  showIndex: boolean;
})}
  <tr
    class="hover select-none {$editingIndex == index ? 'bg-base-300' : ''}"
    onclick={() => ($editingIndex == index ? stopEditing() : startEditing(index))}
  >
    <td>
      <div>
        <div class="flex items-center gap-4">
          {#if showIndex}
            <span class="badge badge-outline badge-primary">{getCharacters(index)}</span>
          {/if}
          <span>{item.name}</span>
        </div>
        {#if item.customizations && item.customizations.length > 0}
          <div class="mt-1 flex flex-wrap gap-1">
            {#each item.customizations as customization (customization.id)}
              {#if customization.name}
                {@render CustomizationBadge({ customization })}
              {/if}
            {/each}
          </div>
        {/if}
      </div>
    </td>
    <td>
      <span>{item.price},-</span>
      {#if $editingIndex === index}
        <button class="btn btn-error ml-3" onclick={deleteEditingItem}><TrashIcon /></button>
      {/if}
    </td>
  </tr>
{/snippet}

{#snippet CartFooter()}
  <tr>
    <th>Total: {$cart.length}</th>
    <th class="text-primary">{$totalPrice},-</th>
  </tr>
{/snippet}
