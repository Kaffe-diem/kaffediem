<script lang="ts">
  import { CustomizationValue } from "$lib/types";
  import { customizationKeys, customizationValues } from "$stores/menuStore";
  import { selectedCustomizations, selectCustomization } from "$stores/cartStore";

  const getValuesByKey = (keyId: string): CustomizationValue[] => 
    $customizationValues.filter((value) => value.belongsTo === keyId);

  export const getSelectedCustomizationsForItem = (): CustomizationValue[] => 
    Object.entries($selectedCustomizations)
      .map(([keyId, valueId]) => $customizationValues.find((v) => v.id === valueId))
      .filter(Boolean) as CustomizationValue[];

</script>

<div class="overflow-y-auto">
  <div class="grid-auto-flow-column grid auto-rows-min grid-cols-2 gap-x-6 gap-y-4">
    {#each $customizationKeys as key}
      <div class="grid grid-cols-1 gap-y-2 p-2">
        <div class="font-medium">{key.name}</div>
        {#each getValuesByKey(key.id) as value}
          <label class="grid cursor-pointer grid-cols-[auto_1fr_auto] items-center gap-x-2">
            <input
              type="radio"
              class="radio radio-sm"
              name={key.id}
              value={value.id}
              onchange={() => selectCustomization(key.id, value.id)}
            />
            <span>{value.name}</span>
            {#if value.priceIncrementNok && value.priceIncrementNok > 0}
              <span class="justify-self-end text-sm text-primary">+{value.priceIncrementNok},-</span
              >
            {/if}
          </label>
        {/each}
      </div>
    {/each}
  </div>
</div>
