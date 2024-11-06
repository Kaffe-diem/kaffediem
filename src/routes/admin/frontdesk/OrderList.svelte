<script lang="ts">
  import { State, Order } from "$lib/types";

  export let orders: Order[];
  export let filter: State;
</script>

<ul class="flex-col">
  {#each orders as order}
    {#if order.state == filter}
      <li>
        <button class="btn mt-4 w-full text-xl font-normal md:btn-lg md:text-3xl">{order.id}</button
        >
      </li>
    {/if}
  {/each}
</ul>
