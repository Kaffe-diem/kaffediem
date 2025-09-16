<script lang="ts">
  import orders from "$stores/orderStore";
  import { OrderStateOptions } from "$lib/pocketbase";

  interface Props {
    show: OrderStateOptions[];
    label: string;
    class?: string;
  }

  let { show, label = "", class: className = "" }: Props = $props();
</script>

<div class="flex h-full flex-col p-4 select-none">
  {#if label != ""}
    <h2 class="mb-4 text-[clamp(1.75rem,4vw,5rem)] leading-tight font-bold md:mb-6 md:text-center">
      {label}
    </h2>
  {/if}
  <div class="grid max-h-full grid-cols-2 gap-6 overflow-y-auto md:grid-cols-3">
    {#each $orders as order}
      {#if show.includes(order?.state)}
        <div
          class="{className} rounded-xl px-4 py-6 text-center text-[clamp(3.5rem,12vw,18rem)] leading-none font-bold"
        >
          {order.dayId}
        </div>
      {/if}
    {/each}
  </div>
</div>
