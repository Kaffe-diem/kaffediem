<script lang="ts">
  import type { CustomizationKey, CustomizationValue } from "$lib/types";
  import { menuIndexes } from "$stores/menu";
  import {
    selectedCustomizations,
    initializeCustomizations,
    toggleCustomization,
    selectedCategory
  } from "$stores/cart";
  import { onMount } from "svelte";

  onMount(() => {
    initializeCustomizations();
  });

  const isValid = (key: CustomizationKey) =>
    key.enable && $selectedCategory?.valid_customizations.includes(key.id);
</script>

<div class="grid h-full grid-rows-[1fr_auto] overflow-y-auto">
  {#if $menuIndexes.customization_keys.some(isValid)}
    <div class="columns-2">
      {#each $menuIndexes.customization_keys as key (key.id)}
        {#if isValid(key)}
          {@render CustomizationCategory({ key })}
        {/if}
      {/each}
    </div>
  {:else}
    <div class="grid items-center text-center">
      <i>Ingen tilgjengelige tilpasninger</i>
    </div>
  {/if}
</div>

{#snippet CustomizationCategory({ key }: { key: CustomizationKey })}
  {@const values = $menuIndexes.customizations_by_key[key.id] ?? []}
  {#if values.filter((value) => value.enable).length > 0}
    <div class="inline-grid w-full grid-cols-1 gap-y-2 p-2">
      <div class="text-primary font-bold xl:text-xl">
        {key.name}
      </div>
      {#each values as value (value.id)}
        {#if value.enable}
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
    style="background-color: {selected ? key.label_color : ''};"
  >
    <input
      type={key.multiple_choice ? "checkbox" : "radio"}
      class="hidden"
      checked={selected}
      onclick={() => toggleCustomization(key, value)}
    />
    <span class="flex w-full justify-between font-normal">
      <span>{value.name}</span>
      {#if value.price_increment_nok != 0 && value.constant_price}
        <span>{value.price_increment_nok},-</span>
      {/if}
      {#if !value.constant_price}
        <span>{value.price_increment_nok}%</span>
      {/if}
    </span>
  </label>
{/snippet}
