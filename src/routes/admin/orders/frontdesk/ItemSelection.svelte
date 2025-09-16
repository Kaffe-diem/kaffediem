<script lang="ts">
  import {
    categories,
    itemsByCategory,
    customizationKeys,
    customizationValues
  } from "$stores/menuStore";
  import type { Item, Category } from "$lib/types";
  import { selectedCustomizations } from "$stores/cartStore";

  let { selectedItem = $bindable() } = $props();

  function syncCustomizations(category: Category) {
    for (const key of $customizationKeys) {
      const isValid = category.customizationKeys.includes(key.id);
      if (!isValid) {
        $selectedCustomizations[key.id] = [];
        continue;
      }

      const selected = $selectedCustomizations[key.id] ?? [];
      if (selected.length === 0 && key.defaultValue) {
        $selectedCustomizations[key.id] = $customizationValues.filter(
          (val) => val.id === key.defaultValue
        );
      }
    }
  }
</script>

<div class="flex h-full flex-col overflow-x-hidden overflow-y-auto">
  {#each $categories as category (category.id)}
    {#if category.enabled}
      {@render CategorySection({ category })}
    {/if}
  {/each}
</div>

{#snippet CategorySection({ category }: { category: Category })}
  {#if ($itemsByCategory[category.id] ?? []).filter((item) => item.enabled).length > 0}
    <div class="mr-2 mb-4 ml-2">
      <h1 class="text-primary mb-2 font-bold xl:text-xl">{category.name}</h1>
      <div class="grid grid-cols-2 gap-4 xl:grid-cols-4">
        {#each $itemsByCategory[category.id] ?? [] as item (item.id)}
          {#if item.enabled}
            {@render ItemCard({ item, category })}
          {/if}
        {/each}
      </div>
    </div>
  {/if}
{/snippet}

{#snippet ItemCard({ item, category }: { item: Item; category: Category })}
  <label>
    <input
      type="radio"
      name="item"
      class="peer hidden"
      value={item}
      bind:group={selectedItem}
      onchange={() => syncCustomizations(category)}
    />
    <div
      class="btn peer-checked:border-accent peer-checked:bg-base-300 peer-checked:ring-lg peer-checked:ring-accent relative flex h-24 w-full flex-col border-2 transition-all duration-300 ease-in-out peer-checked:scale-109 peer-checked:shadow-xl peer-checked:ring"
    >
      <span class="text-xs font-bold xl:text-lg">{item.name}</span>
      <span class="absolute right-1 bottom-1 font-normal">{item.price},-</span>
    </div>
  </label>
{/snippet}
