<script lang="ts">
  import { State, Order } from "$lib/types";

  export let orders: Order[];
  export let filter: State;
</script>

<ul class="flex-col">
  {#each orders as order}
    {#if order.state == filter}
      <li>
        <button class="btn btn-lg m-2 w-full text-3xl font-normal">{order.id}</button>
      </li>
    {/if}
  {/each}
</ul>
