<script lang="ts">
  import type { OrderStateOptions } from "$lib/pocketbase";
  import orders from "$stores/orderStore";
  import { customizationKeys } from "$lib/stores/menuStore";
  import type { CustomizationKey, CustomizationValue, Order, OrderItem } from "$lib/types";
  import CommentIcon from "$assets/CommentIcon.svelte";

  const {
    show,
    onclick,
    label,
    detailed = true
  } = $props<{
    show: OrderStateOptions[];
    onclick: OrderStateOptions;
    label: string;
    detailed?: boolean;
  }>();

  function getKeyById(keyId: string): CustomizationKey | undefined {
    const keys = $customizationKeys as CustomizationKey[];

    return keys.find((key: CustomizationKey) => key.id === keyId);
  }
</script>

<div class="h-full w-full overflow-y-auto">
  <h2
    class="text-neutral sticky pb-2 text-center text-4xl font-bold md:mb-6"
    id="order-list-heading"
  >
    {label}
  </h2>
  <table class="table" aria-labelledby="order-list-heading">
    <thead class="sr-only">
      <tr>
        <th>Order Number</th>
        {#if detailed}<th>Order Items</th>{/if}
      </tr>
    </thead>
    <tbody class="space-y-4">
      {#each $orders.reverse() as order, index}
        {#if show.includes(order.state)}
          {@render OrderRow({
            order,
            orderNumber: $orders.length - index - 1 + 100
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
    onclick={() => orders.updateState(order.id, onclick)}
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
          {#each order.items as orderItem}
            {@render OrderItem({ orderItem })}
          {/each}
        </ul>
      </td>
    {/if}
  </tr>
{/snippet}

{#snippet OrderItem({ orderItem }: { orderItem: OrderItem })}
  <li class="bg-base-300 w-full rounded p-3 shadow">
    <div class="flex flex-col">
      <span class="mb-1 text-xl">
        {orderItem.item.name}
      </span>

      {#if orderItem.customizations && orderItem.customizations.length > 0}
        <ul class="mt-1 flex flex-wrap gap-1" aria-label="Customizations">
          {#each orderItem.customizations as customization}
            {#if customization.name}
              {@render CustomizationBadge({ customization })}
            {/if}
          {/each}
        </ul>
      {/if}
    </div>
  </li>
{/snippet}

{#snippet CustomizationBadge({ customization }: { customization: CustomizationValue })}
  {@const keyId = customization.belongsTo || ""}
  {@const key = getKeyById(keyId)}
  {@const keyColor = key?.labelColor}
  {@const keyName = key?.name || "Option"}
  <li>
    <span
      class="badge badge-lg px-2 py-1 text-xl"
      style={keyColor ? `background-color: ${keyColor}; color: white;` : ""}
      aria-label={`${keyName}: ${customization.name}`}
    >
      {customization.name}
    </span>
  </li>
{/snippet}
