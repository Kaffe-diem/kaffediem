<script lang="ts">
  import OrderItem from "$components/OrderItem.svelte";
  import { State, Order } from "$lib/types";

  export let orders: Order[];
  export let filter: State;
</script>

<div class="flex flex-wrap gap-2">
  {#each orders as order}
    {#if order.state == filter}
      <OrderItem>{order.id}</OrderItem>
    {/if}
  {/each}
</div>
