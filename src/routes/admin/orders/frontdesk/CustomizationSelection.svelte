<script lang="ts">
  import { CustomizationKey, CustomizationValue } from "$lib/types";
  import { customizationKeys, customizationValues } from "$stores/menuStore";
  import { selectedCustomizations, selectCustomization } from "$stores/cartStore";

  const getValuesByKey = (keyId: string): CustomizationValue[] =>
    $customizationValues.filter((value) => value.belongsTo === keyId);

  export const getSelectedCustomizationsForItem = (): CustomizationValue[] =>
    Object.entries($selectedCustomizations)
      .map(([, valueId]) => $customizationValues.find((v) => v.id === valueId))
      .filter(Boolean) as CustomizationValue[];
</script>

<div class="overflow-y-auto">
  <div class="grid-auto-flow-column grid auto-rows-min grid-cols-2 gap-x-6 gap-y-4">
    {#each $customizationKeys as key}
      {@render CustomizationCategory({ key })}
    {/each}
  </div>
</div>

{#snippet CustomizationCategory({ key }: { key: CustomizationKey })}
  <div class="grid grid-cols-1 gap-y-2 p-2">
    <div class="font-medium">
      {key.name}
      {#if key.name === "Ekstra"}
        <span class="text-primary">+{5},-</span>
      {/if}
    </div>
    {#each getValuesByKey(key.id) as value}
      {@render CustomizationOption({ key, value })}
    {/each}
  </div>
{/snippet}

{#snippet CustomizationOption({ key, value }: { key: CustomizationKey; value: CustomizationValue })}
  <div>
    <button
      class="btn relative flex w-full items-center justify-between border-2 px-3 py-2
             transition-all duration-200 ease-in-out hover:bg-opacity-90 focus:outline-none
             {$selectedCustomizations[key.id] === value.id
        ? 'border-amber-500'
        : 'border-base-300'}"
      style="background-color: {key.labelColor || 'inherit'};"
      onclick={() => selectCustomization(key.id, value.id)}
    >
      <span>{value.name}</span>
    </button>
  </div>
{/snippet}
