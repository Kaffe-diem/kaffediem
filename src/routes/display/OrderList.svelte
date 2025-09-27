<script lang="ts">
  import orders from "$stores/orderStore";
  import { OrderStateOptions } from "$lib/pocketbase";

  interface Props {
    show: OrderStateOptions[];
    label: string;
    class?: string;
  }

  let { show, label = "", class: className = "" }: Props = $props();

  const stateOrder = {
    [OrderStateOptions.production]: 0,
    [OrderStateOptions.received]: 1,
    [OrderStateOptions.completed]: 2,
    [OrderStateOptions.dispatched]: 3
  };
</script>

<div class="flex h-full flex-col p-4 select-none">
  {#if label != ""}
    <h2
      class="mb-4 text-[clamp(1.75rem,3vw,4.25rem)] leading-tight font-bold md:mb-6 md:text-center"
    >
      {label}
    </h2>
  {/if}
  <div class="grid max-h-full grid-cols-3 gap-4 overflow-x-hidden overflow-y-scroll xl:grid-cols-4">
    {#each $orders.sort((a, b) => {
      const stateDiff = stateOrder[a.state] - stateOrder[b.state];
      return stateDiff !== 0 ? stateDiff : b.dayId - a.dayId;
    }) as order (order.id)}
      {#if show.includes(order?.state)}
        <div
          class="{className} {order.state == OrderStateOptions.production
            ? 'bg-warning'
            : ''} rounded-xl px-4 py-4 text-center text-[clamp(3rem,4vw,12rem)] leading-none font-bold"
        >
          {order.dayId}
        </div>
      {/if}
    {/each}
  </div>
</div>
