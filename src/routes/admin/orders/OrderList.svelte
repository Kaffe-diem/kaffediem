<script lang="ts">
  import { $props } from "svelte";
  import type { OrderStateOptions, RecordIdString } from "$lib/pocketbase";
  import orders from "$stores/orderStore";
  import { customizationKeys } from "$lib/stores/menuStore";
  import type { CustomizationKey, Order } from "$lib/types";

  const { show, onclick, label } = $props<{
    show: OrderStateOptions[];
    onclick: OrderStateOptions;
    label: string;
  }>();

  // Helper function to get customization key by id
  function getKeyById(keyId: string): CustomizationKey | undefined {
    const keys = $customizationKeys as CustomizationKey[];
    return keys.find((key: CustomizationKey) => key.id === keyId);
  }
</script>

<div class="h-full w-full overflow-y-auto">
  <h2
    class="sticky top-0 z-50 bg-base-100 pb-2 text-center text-4xl font-bold text-neutral md:mb-6"
  >
    {label}
  </h2>
  <table class="table table-sm table-auto">
    <tbody>
      {#each $orders as order}
        {#if order && show.includes(order.state)}
          <tr class="hover border-none" onclick={() => orders.updateState(order.id, onclick)}>
            <td class="text-lg">{$orders.indexOf(order) + 100}</td>
            <td>
              {#each order.items as orderItem}
                <div class="mb-2">
                  <span class="badge badge-ghost m-1 whitespace-nowrap p-3 text-lg">
                    {orderItem.item.name}
                  </span>
                  
                  {#if orderItem.item.customizations && orderItem.item.customizations.length > 0}
                    <div class="flex flex-wrap gap-1 mt-1 ml-2">
                      {#each orderItem.item.customizations as customization}
                        {#if customization.name}
                          <span 
                            class="badge badge-sm" 
                            style={
                              getKeyById(customization.belongsTo || '')?.labelColor 
                                ? `background-color: ${getKeyById(customization.belongsTo || '')?.labelColor}; color: white;` 
                                : ''
                            }
                          >
                            {customization.name}
                          </span>
                        {/if}
                      {/each}
                    </div>
                  {/if}
                </div>
              {/each}
            </td>
          </tr>
        {/if}
      {/each}
    </tbody>
  </table>
</div>
