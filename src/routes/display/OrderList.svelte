<script lang="ts">
  import type { State } from "$lib/types";

  interface Props {
    // this is a custom store of Order[], I am not sure how to type it.
    orders: any;
    show: State[];
  }

  let { orders, show }: Props = $props();
</script>

<div class="flex flex-wrap gap-2">
  {#each $orders as order}
    {#if show.includes(order.state)}
      <button class="btn btn-lg bg-base-200 text-3xl font-normal text-neutral"
        >{order.id.slice(0, 4)}</button
      >
    {/if}
  {/each}
</div>
