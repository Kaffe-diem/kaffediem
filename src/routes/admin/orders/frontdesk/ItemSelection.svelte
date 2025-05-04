<script lang="ts">
  import { categories, itemsByCategory } from "$stores/menuStore";
  import type { Item, Category } from "$lib/types";

  let { selectedItem = $bindable() } = $props();
</script>

<div class="flex h-full flex-col overflow-y-auto">
  {#each $categories as category}
    {#if category.enabled}
      {@render CategorySection({ category })}
    {/if}
  {/each}
</div>

{#snippet CategorySection({ category }: { category: Category })}
  <div class="mb-8">
    <h1 class="text-primary mb-4 text-lg font-bold xl:text-2xl">{category.name}</h1>
    <div class="grid grid-cols-1 gap-6 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4">
      {#each $itemsByCategory[category.id] ?? [] as item}
        {#if item.enabled}
          {@render ItemCard({ item })}
        {/if}
      {/each}
    </div>
  </div>
{/snippet}

{#snippet ItemCard({ item }: { item: Item })}
  <label>
    <input type="radio" name="item" class="peer hidden" value={item} bind:group={selectedItem} />
    <div
      class="btn peer-checked:border-accent relative flex h-24 w-full flex-col items-center justify-center border-4"
    >
      <span class="font-bold">{item.name}</span>
      <span class="absolute right-2 bottom-2 font-normal">{item.price},-</span>
    </div>
  </label>
{/snippet}
