<script lang="ts">
  import type { State } from "$lib/types";
  interface Props {
    // this is a custom store Order[], I am not sure how to type it.
    orders: any;
    show: State;
  }

  let { orders, show }: Props = $props();
</script>

<div class="overflow-y-auto">
  <ul class="flex-col">
    {#each $orders as order}
      {#if order.state === show}
        <li>
          <!-- maybe on hover/click (if click, swipe to delete) we can show the contents? -->
          <button
            class="btn mt-4 w-full text-xl font-normal md:btn-lg md:text-3xl"
            onclick={() => orders.setState(order.id, "dispatched")}
          >
            {order.id.slice(0, 4)}
          </button>
        </li>
      {/if}
    {/each}
  </ul>
</div>
