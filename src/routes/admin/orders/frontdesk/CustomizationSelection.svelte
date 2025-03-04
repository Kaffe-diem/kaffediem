<script lang="ts">
  import { Item, CustomizationKey, CustomizationValue } from "$lib/types";
  import { customizationKeys, customizationValues } from "$stores/menuStore";
  import { selectedCustomizations, selectCustomization } from "$stores/cartStore";
  
  export let selectedItem: Item | null = null;
  
  $: customizationPrice = Object.values($selectedCustomizations).reduce((total, valueId) => {
    const value = $customizationValues.find(v => v.id === valueId);
    return total + (value?.priceIncrementNok || 0);
  }, 0);
  
  // Helper function to get values for a key
  function getValuesByKey(keyId: string): CustomizationValue[] {
    return $customizationValues.filter(value => value.belongsTo === keyId);
  }
  
  // Helper function to get customization key by id
  function getKeyById(keyId: string): CustomizationKey | undefined {
    return $customizationKeys.find(key => key.id === keyId);
  }
  
  // Helper function to split customization keys into two columns
  function splitIntoColumns(keys: CustomizationKey[]): [CustomizationKey[], CustomizationKey[]] {
    const midpoint = Math.ceil(keys.length / 2);
    return [keys.slice(0, midpoint), keys.slice(midpoint)];
  }
  
  // Handle radio button change
  function handleCustomizationChange(keyId: string, valueId: string) {
    selectCustomization(keyId, valueId);
  }
  
  // Get selected customization values for an item
  export function getSelectedCustomizationsForItem(): CustomizationValue[] {
    return Object.entries($selectedCustomizations).map(([keyId, valueId]) => {
      return $customizationValues.find(v => v.id === valueId);
    }).filter(Boolean) as CustomizationValue[];
  }
</script>

<div class="overflow-y-auto">
  {#if $customizationKeys.length > 0}
    <div class="grid grid-cols-2 gap-x-6 gap-y-4">
      {#each splitIntoColumns($customizationKeys) as columnKeys, columnIndex}
        {#each columnKeys as key}
          {#if key.name}
            <div class="p-2">
              <div class="font-medium mb-2">{key.name}</div>
              
              <div class="grid grid-cols-1 gap-y-2">
                {#if getValuesByKey(key.id).length > 0}
                  {#each getValuesByKey(key.id) as value}
                    <label class="grid grid-cols-[auto_1fr_auto] items-center gap-x-2 cursor-pointer">
                      <input 
                        type="radio" 
                        class="radio radio-sm" 
                        name={key.id} 
                        value={value.id}
                        onchange={() => handleCustomizationChange(key.id, value.id)} 
                      /> 
                      <span>{value.name}</span>
                      {#if value.priceIncrementNok && value.priceIncrementNok > 0}
                        <span class="text-primary text-sm justify-self-end">+{value.priceIncrementNok},-</span>
                      {/if}
                    </label>
                  {/each}
                {:else}
                  <p class="text-sm text-neutral">No options available</p>
                {/if}
              </div>
            </div>
          {/if}
        {/each}
      {/each}
    </div>
  {:else}
    <div class="my-4">
      <p class="text-neutral">Loading customization options...</p>
    </div>
  {/if}
</div> 