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
    <h2 class="mb-4 text-4xl font-bold md:mb-6 md:text-center lg:text-4xl">
      {label}
    </h2>
  {/if}
  <div class="grid max-h-full grid-cols-3 gap-4 overflow-y-scroll">
    {#each $orders as order (order.id)}
      {#if show.includes(order?.state)}
        <div class="{className} xl:text-10xl rounded-xl px-4 py-4 text-center text-6xl font-bold">
          {order.dayId}
        </div>
      {/if}
    {/each}
  </div>
</div>
