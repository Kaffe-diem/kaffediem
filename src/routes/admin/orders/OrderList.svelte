<script lang="ts">
  import type { OrderStateOptions } from "$lib/types";
  import orders from "$stores/orderStore";
  import { customizationKeys } from "$lib/stores/menuStore";
  import type { CustomizationKey, Order, OrderItemSnapshot } from "$lib/types";
  import CommentIcon from "$assets/CommentIcon.svelte";
  import { getCharacters } from "$lib/utils";

  const {
    show,
    onclick,
    label,
    detailed = true
  } = $props<{
    show: OrderStateOptions[];
    onclick?: OrderStateOptions;
    label: string;
    detailed?: boolean;
  }>();

  function getKeyById(keyId: string): CustomizationKey | undefined {
    const keys = $customizationKeys as CustomizationKey[];

    return keys.find((key: CustomizationKey) => key.id === keyId);
  }

  function amount() {
    return $orders.filter((order) => show.includes(order.state)).length;
  }
</script>

<div class="h-full w-full overflow-y-auto">
  <h2
    class="text-neutral sticky pb-2 text-center text-2xl font-bold md:mb-6"
    id="order-list-heading"
  >
    {amount() > 0 ? `${label}: ${amount()}` : label}
  </h2>
  <table class="table" aria-labelledby="order-list-heading">
    <thead class="sr-only">
      <tr>
        <th>Order Number</th>
        {#if detailed}<th>Order Items</th>{/if}
      </tr>
    </thead>
    <tbody class="space-y-4">
      {#if amount() == 0}
        <tr><td class="text-center italic">ingenting</td></tr>
      {/if}
      {#each $orders.sort((a, b) => b.dayId - a.dayId) as order (order.id)}
        {#if show.includes(order.state)}
          {@render OrderRow({
            order,
            orderNumber: order.dayId
          })}
        {/if}
      {/each}
    </tbody>
  </table>
</div>

{#snippet OrderRow({ order, orderNumber }: { order: Order; orderNumber: number })}
  <tr
    class="{!detailed
      ? 'btn btn-xl ml-4 h-16'
      : 'bg-base-200 cursor-pointer'}  {order.missingInformation && detailed
      ? 'bg-warning ring-warning'
      : ''} mb-6 block rounded shadow-md transition-colors"
    data-testid="order-row"
    data-order-number={orderNumber}
    onclick={() => onclick && orders.updateState(order.id, onclick)}
    role="button"
    tabindex="0"
    onkeydown={(e) => e.key === "Enter" && orders.updateState(order.id, onclick)}
    aria-label={`Order ${orderNumber} with ${order.items.length} items`}
  >
    <td class="{!detailed ? 'flex justify-center' : ''} text-4xl font-bold"
      >{orderNumber}{#if order.missingInformation && detailed}<CommentIcon />{/if}</td
    >
    {#if detailed}
      <td class="w-full">
        <ul class="space-y-2">
          {#each order.items as orderItem, index (index)}
            {@render OrderItem({ orderItem, index, showIndex: order.items.length > 1 })}
          {/each}
        </ul>
      </td>
    {/if}
  </tr>
{/snippet}

{#snippet OrderItem({
  orderItem,
  index,
  showIndex
}: {
  orderItem: OrderItemSnapshot;
  index: number;
  showIndex: boolean;
})}
  <li class="bg-base-300 w-full rounded p-3 shadow">
    <div class="flex flex-col">
      <div class="flex flex-row items-center gap-4">
        {#if showIndex}
          <span class="badge badge-outline badge-primary flex items-center text-xl">
            {getCharacters(index)}
          </span>
        {/if}
        <span class="flex items-center text-xl">
          {orderItem.name}
        </span>
      </div>

      {#if orderItem.customizations && orderItem.customizations.length > 0}
        <ul class="mt-1 flex flex-wrap gap-1" aria-label="Customizations">
          {#each orderItem.customizations as customization, custIdx (custIdx)}
            {#if customization.valueName}
              {@render CustomizationBadge({ customization })}
            {/if}
          {/each}
        </ul>
      {/if}
    </div>
  </li>
{/snippet}

{#snippet CustomizationBadge({
  customization
}: {
  customization: {
    keyId: string;
    keyName: string;
    valueId: string;
    valueName: string;
    priceChange: number;
  };
})}
  {@const key = getKeyById(customization.keyId)}
  {@const keyColor = key?.labelColor}
  <li>
    <span
      class="badge badge-lg px-2 py-1 text-xl"
      style={keyColor ? `background-color: ${keyColor}; color: white;` : ""}
      aria-label={`${customization.keyName}: ${customization.valueName}`}
    >
      {customization.valueName}
    </span>
  </li>
{/snippet}
