<script lang="ts">
  import { categories, itemsByCategory } from "$stores/menuStore";
  import type { Item, Category } from "$lib/types";

  let { selectedItem = $bindable() } = $props();
</script>

<div class="flex h-full flex-col overflow-x-hidden overflow-y-auto">
  {#each $categories as category}
    {#if category.enabled}
      {@render CategorySection({ category })}
    {/if}
  {/each}
</div>

{#snippet CategorySection({ category }: { category: Category })}
  <div class="mr-2 mb-4 ml-2">
    <h1 class="text-primary mb-2 font-bold xl:text-xl">{category.name}</h1>
    <div class="grid grid-cols-1 gap-4 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4">
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
      class="btn peer-checked:border-accent peer-checked:bg-base-300 peer-checked:ring-lg peer-checked:ring-accent relative flex h-24 w-full flex-col border-2 transition-all duration-300 ease-in-out peer-checked:scale-109 peer-checked:shadow-xl peer-checked:ring"
    >
      <span class="font-bold xl:text-lg">{item.name}</span>
      <span class="absolute right-1 bottom-1 font-normal">{item.price},-</span>
    </div>
  </label>
{/snippet}
