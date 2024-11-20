<script lang="ts">
  import type { State } from "$lib/types";
  interface Props {
    // this is a custom store Order[], I am not sure how to type it.
    orders: any;
    show: State[];
    onclick: string;
    label: string;
  }

  let { orders, show, onclick, label }: Props = $props();
</script>

<div class="h-full w-full overflow-y-auto">
  <h2
    class="sticky top-0 z-50 bg-base-100 pb-2 text-center text-4xl font-bold text-neutral md:mb-6"
  >
    {label}
  </h2>
  <table class="table table-sm table-auto">
    <thead>
      <tr>
        <th>ID</th>
        <th>Innhold</th>
      </tr>
    </thead>
    <tbody>
      {#each $orders as order, index}
        {#if show.includes(order.state)}
          <tr class="hover" onclick={() => orders.setState(order.id, onclick)}>
            <td>{index + 100}</td>
            <td>
              {#each order.drinks as drink}
                <span class="badge badge-ghost m-1 whitespace-nowrap">
                  {drink.name}
                </span>
              {/each}
            </td>
          </tr>
        {/if}
      {/each}
    </tbody>
  </table>
</div>
