<script lang="ts">
  import orders from "$stores/orderStore";
  import { OrderStateOptions } from "$lib/pocketbase";

  interface Props {
    show: OrderStateOptions[];
    label: string;
    class?: string;
  }

  let { show, label, class: className = "" }: Props = $props();
</script>

<div class="flex h-full flex-col p-4 select-none">
  <h2 class="mb-3 text-4xl font-bold md:mb-6 md:text-center lg:text-6xl {className}">
    {label}
  </h2>
  <div class="grid max-h-full grid-cols-4 gap-2 overflow-y-scroll">
    {#each $orders as order, index}
      {#if show.includes(order?.state)}
        <div class="bg-base-200 text-neutral px-4 py-4 text-center text-4xl">
          {index + 100}
        </div>
      {/if}
    {/each}
  </div>
</div>
