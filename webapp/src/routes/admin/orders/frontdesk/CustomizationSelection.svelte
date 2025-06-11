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

<div class="grid h-full grid-rows-[1fr_auto] overflow-y-auto">
  <div class="grid-auto-flow-column grid auto-rows-min gap-x-6 gap-y-4 md:grid-cols-2">
    {#each $customizationKeys as key (key.id)}
      {#if key.enabled}
        {@render CustomizationCategory({ key })}
      {/if}
    {/each}
  </div>
</div>

{#snippet CustomizationCategory({ key }: { key: CustomizationKey })}
  <div class="grid grid-cols-1 gap-y-2 p-2">
    <div class="text-primary font-bold xl:text-xl">
      {key.name}
    </div>
    {#each getValuesByKey(key.id) as value (value.id)}
      {#if value.enabled}
        {@render CustomizationOption({ key, value })}
      {/if}
    {/each}
  </div>
{/snippet}

{#snippet CustomizationOption({ key, value }: { key: CustomizationKey; value: CustomizationValue })}
  {@const selected = $selectedCustomizations[key.id]?.some((v) => v.id === value.id)}
  <button
    class="btn {selected
      ? 'ring-lg ring-accent scale-109 text-white shadow-xl ring'
      : ''} flex w-full transition-all duration-300 ease-in-out hover:brightness-90 focus:outline-none"
    style="background-color: {selected ? key.labelColor : ''};"
    onclick={() => selectCustomization(key.id, value)}
  >
    <span class="flex w-full justify-between">
      <span>{value.name}</span>
      {#if value.priceChange != 0 && value.constantPrice}
        <span>{value.priceChange},-</span>
      {/if}
      {#if !value.constantPrice}
        <span>{value.priceChange}%</span>
      {/if}
    </span>
  </button>
{/snippet}
