<script lang="ts">
  import { State, Order } from "$lib/types";

  export let orders: Order[];
  export let filter: State;
</script>

<div class="flex flex-wrap gap-2">
  {#each orders as order}
    {#if order.state == filter}
      <button class="btn btn-lg bg-base-200 text-3xl font-normal text-neutral">{order.id}</button>
    {/if}
  {/each}
</div>
