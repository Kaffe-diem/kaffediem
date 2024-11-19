<script lang="ts">
  import type { State } from "$lib/types";
  interface Props {
    // this is a custom store Order[], I am not sure how to type it.
    orders: any;
    show: State[];
    onclick: string;
  }

  let { orders, show, onclick }: Props = $props();
</script>

<div class="overflow-y-auto">
  <ul class="flex-col">
    {#each $orders as order, index}
      {#if show.includes(order.state)}
        <li>
          <!-- maybe on hover/click (if click, swipe to delete) we can show the contents? -->
          <button
            class="btn mt-4 flex w-full space-x-2 text-xl font-normal md:btn-lg md:text-3xl"
            onclick={() => orders.setState(order.id, onclick)}
          >
            {index + 100}
            {#each order.expand.drinks as drink}
              <span class="badge badge-primary">
                {drink.expand.drink.name}
              </span>
            {/each}
          </button>
        </li>
      {/if}
    {/each}
  </ul>
</div>
