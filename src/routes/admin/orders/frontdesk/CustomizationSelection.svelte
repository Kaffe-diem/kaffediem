<script lang="ts">
  import { CustomizationKey, CustomizationValue, Item, Category } from "$lib/types";
  import { customizationKeys, customizationValues } from "$stores/menuStore";
  import {
    selectedCustomizations,
    selectCustomization,
    initializeCustomizations
  } from "$stores/cartStore";
  import { onMount } from "svelte";
  import { categories } from "$stores/menuStore";

  const getValuesByKey = (keyId: string): CustomizationValue[] => {
    return $customizationValues.filter((value) => value.belongsTo === keyId);
  };

  const getCategoryById = (categoryId: string): Category | undefined => {
    return $categories.find((value) => value.id === categoryId);
  };

  onMount(() => {
    initializeCustomizations();
  });

  let { selectedItem } = $props<{
    selectedItem: Item | undefined;
  }>();

  let selectedCategory = $derived(
    selectedItem ? getCategoryById(selectedItem.category) : undefined
  );
</script>

<div class="grid h-full grid-rows-[1fr_auto] overflow-y-auto">
  <div class="grid-auto-flow-column grid grid-cols-2">
    {#each $customizationKeys as key}
      {#if key.enabled && selectedCategory?.validCustomizationKeys.includes(key.id)}
        {@render CustomizationCategory({ key })}
      {/if}
    {/each}
  </div>
</div>

{#snippet CustomizationCategory({ key }: { key: CustomizationKey })}
  {#if getValuesByKey(key.id).filter((value) => value.enabled).length > 0}
    <div class="grid grid-cols-1 gap-y-2 p-2">
      <div class="text-primary font-bold xl:text-xl">
        {key.name}
      </div>
      {#each getValuesByKey(key.id) as value}
        {#if value.enabled}
          {@render CustomizationOption({ key, value })}
        {/if}
      {/each}
    </div>
  {/if}
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
    <span class="flex w-full justify-between font-normal">
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
