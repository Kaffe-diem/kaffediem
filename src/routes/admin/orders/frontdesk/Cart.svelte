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
  } from "$stores/cartStore";
  import auth from "$stores/authStore";
  import orderStore from "$stores/orderStore";
  import { customizationKeys } from "$stores/menuStore";
  import { type CustomizationValue } from "$lib/types";
  import orders from "$stores/orderStore";
  import CommentIcon from "$assets/CommentIcon.svelte";
  import CompleteOrder from "$assets/CompleteOrder.svelte";
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

  let remoteOrderId = $derived(
    $orders.length > 0 ? $orders.sort((a, b) => a.dayId - b.dayId).at(-1)!.dayId : 100
  );
  let localOrderId = $derived(remoteOrderId);
  let currentOrderId = $derived(Math.max(localOrderId, remoteOrderId));

  let missing_information = $state(false);
  function completeOrder() {
    orderStore.create($auth.user.id, $cart, missing_information, currentOrderId + 1);
    localOrderId += 1;
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
    <div class="relative inline-flex items-center gap-2">
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

      <button class="bold btn btn-lg {$cart.length > 0 ? '' : 'invisible'}" onclick={completeOrder}>
        <CompleteOrder />{currentOrderId + 1}
      </button>

      {#if $orders.length > 0}
        <span
          class="{$cart.length > 0
            ? 'hidden'
            : ''} pointer-events-none absolute inset-0 flex items-center justify-center text-lg font-bold"
        >
          Forrige: {currentOrderId}
        </span>
      {/if}
    </div>

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
        <button class="btn btn-error ml-3" onclick={deleteEditingItem}>slett</button>
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
