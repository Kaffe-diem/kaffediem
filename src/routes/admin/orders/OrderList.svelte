<script lang="ts">
  import type { OrderStateOptions as OrderStateOptions, RecordIdString } from "$lib/pocketbase";
  import orders from "$stores/orderStore";

  interface Props {
    show: OrderStateOptions[];
    onclick: OrderStateOptions;
    label: RecordIdString;
  }

  let { show, onclick, label }: Props = $props();
</script>

<div class="h-full w-full overflow-y-auto">
  <h2
    class="sticky top-0 z-50 bg-base-100 pb-2 text-center text-4xl font-bold text-neutral md:mb-6"
  >
    {label}
  </h2>
  <table class="table table-sm table-auto">
    <tbody>
      {#each $orders as order, index}
        {#if show.includes(order?.state)}
          <tr class="hover border-none" onclick={() => orders.updateState(order?.id, onclick)}>
            <td class="text-lg">{index + 100}</td>
            <td>
              {#each order.items as orderItem}
                <span class="badge badge-ghost m-1 whitespace-nowrap p-3 text-lg">
                  {orderItem.item.name}
                </span>
              {/each}
            </td>
          </tr>
        {/if}
      {/each}
    </tbody>
  </table>
</div>
