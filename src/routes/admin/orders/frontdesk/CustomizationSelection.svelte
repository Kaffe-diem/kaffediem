<script lang="ts">
  import { CustomizationKey, CustomizationValue } from "$lib/types";
  import { customizationKeys, customizationValues } from "$stores/menuStore";
  import {
    selectedCustomizations,
    selectCustomization,
    initializeCustomizations
  } from "$stores/cartStore";
  import { onMount } from "svelte";

  const getValuesByKey = (keyId: string): CustomizationValue[] => {
    return $customizationValues.filter((value) => value.belongsTo === keyId);
  };

  onMount(() => {
    initializeCustomizations();
  });
</script>

<div class="h-full overflow-y-auto">
  <div class="grid-auto-flow-column grid auto-rows-min gap-x-6 gap-y-4 md:grid-cols-2">
    {#each $customizationKeys as key}
      {#if key.enabled}
        {@render CustomizationCategory({ key })}
      {/if}
    {/each}
  </div>
</div>

{#snippet CustomizationCategory({ key }: { key: CustomizationKey })}
  <div class="grid grid-cols-1 gap-y-2 p-2">
    <div class="font-medium">
      {key.name}
    </div>
    {#each getValuesByKey(key.id) as value}
      {#if value.enabled}
        {@render CustomizationOption({ key, value })}
      {/if}
    {/each}
  </div>
{/snippet}

{#snippet CustomizationOption({ key, value }: { key: CustomizationKey; value: CustomizationValue })}
  <div>
    <button
      class="btn {$selectedCustomizations[key.id]?.some((v) => v.id === value.id)
        ? 'ring-lg ring-accent scale-109 text-white shadow-xl ring'
        : ''} bg-base-200 flex w-full transition-all duration-300 ease-in-out hover:brightness-90 focus:outline-none"
      style="background-color: {$selectedCustomizations[key.id]?.some((v) => v.id === value.id)
        ? key.labelColor
        : ''};"
      onclick={() => selectCustomization(key.id, value)}
    >
      <span class="flex w-full justify-between">
        <span>{value.name}</span>
        {#if value.priceIncrementNok > 0}
          <span>{value.priceIncrementNok},-</span>
        {/if}
      </span>
    </button>
  </div>
{/snippet}
