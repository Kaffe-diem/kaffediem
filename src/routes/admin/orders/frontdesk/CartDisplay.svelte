<script lang="ts">
  import { cart, totalPrice, removeFromCart, clearCart } from "$stores/cartStore";
  import type { CustomizationKey } from "$lib/types";
  import { customizationKeys } from "$stores/menuStore";
  
  // Helper function to get customization key by id
  function getKeyById(keyId: string): CustomizationKey | undefined {
    return $customizationKeys.find(key => key.id === keyId);
  }
  

</script>

<div class="overflow-y-auto">
  <table class="table table-pin-rows table-auto list-none shadow-2xl">
    <thead>
      <tr>
        <th class="w-full">Drikke</th>
        <th class="whitespace-nowrap">Pris</th>
      </tr>
    </thead>
    <tbody>
      {#if $cart.length > 0}
        {#each $cart as item, index}
          <tr class="hover select-none" onclick={() => removeFromCart(index)}>
            <td>
              <div>
                <div>{item.name}</div>
                {#if item.customizations && item.customizations.length > 0}
                  <div class="flex flex-wrap gap-1 mt-1">
                    {#each item.customizations as customization}
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
            </td>
            <td>{item.price},-</td>
          </tr>
        {/each}
      {:else}
        <tr>
          <td>Ingenting</td>
          <td></td>
        </tr>
      {/if}
    </tbody>
    <tfoot>
      <tr>
        <th>Total: <span class="text-neutral">{$cart.length}</span></th>
        <th><span class="text-bold text-lg text-primary">{$totalPrice},-</span></th>
      </tr>
    </tfoot>
  </table>
</div>
