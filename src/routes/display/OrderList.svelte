<script lang="ts">
  import { Order } from "$lib/types";
  import type { State } from "$lib/types";

  interface Props {
    orders: Order[];
    show: State;
  }

  let { orders, show }: Props = $props();
</script>

<div class="flex flex-wrap gap-2">
  {#each orders as order}
    {#if order.state == show}
      <button class="btn btn-lg bg-base-200 text-3xl font-normal text-neutral">{order.id}</button>
    {/if}
  {/each}
</div>
