<script lang="ts">
  import { CustomizationKey, CustomizationValue } from "$lib/types";
  import { customizationKeys, customizationsByKey } from "$stores/menuStore";
  import {
    selectedCustomizations,
    initializeCustomizations,
    toggleCustomization,
    selectedCategory
  } from "$stores/cartStore";
  import { onMount } from "svelte";

  onMount(() => {
    initializeCustomizations();
  });
</script>

<div class="grid h-full grid-rows-[1fr_auto] overflow-y-auto">
  <div class="columns-2">
    {#each $customizationKeys as key (key.id)}
      {#if key.enabled && $selectedCategory?.validCustomizations.includes(key.id)}
        {@render CustomizationCategory({ key })}
      {/if}
    {/each}
  </div>
</div>

{#snippet CustomizationCategory({ key }: { key: CustomizationKey })}
  {#if $customizationsByKey[key.id]!.filter((value) => value.enabled).length > 0}
    <div class="inline-grid w-full grid-cols-1 gap-y-2 p-2">
      <div class="text-primary font-bold xl:text-xl">
        {key.name}
      </div>
      {#each $customizationsByKey[key.id]! as value (value.id)}
        {#if value.enabled}
          {@render CustomizationOption({ key, value })}
        {/if}
      {/each}
    </div>
  {/if}
{/snippet}

{#snippet CustomizationOption({ key, value }: { key: CustomizationKey; value: CustomizationValue })}
  {@const selected = $selectedCustomizations[key.id]?.some((v) => v.id === value.id)}
  <label
    class="btn flex w-full cursor-pointer transition-all duration-300 ease-in-out hover:brightness-90 focus:outline-none
      {selected ? 'ring-lg ring-accent text-white shadow-xl ring' : ''}"
    style="background-color: {selected ? key.labelColor : ''};"
  >
    <input
      type={key.multipleChoice ? "checkbox" : "radio"}
      class="hidden"
      checked={selected}
      onclick={() => toggleCustomization(key, value)}
    />
    <span class="flex w-full justify-between font-normal">
      <span>{value.name}</span>
      {#if value.priceChange != 0 && value.constantPrice}
        <span>{value.priceChange},-</span>
      {/if}
      {#if !value.constantPrice}
        <span>{value.priceChange}%</span>
      {/if}
    </span>
  </label>
{/snippet}
