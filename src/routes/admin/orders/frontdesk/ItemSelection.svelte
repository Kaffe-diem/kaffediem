<script lang="ts">
  import { categories } from "$stores/menuStore";
  import type { Item } from "$lib/types";
  import type { Category } from "$lib/types";

  let { selectedItem = $bindable() } = $props();
</script>

<div class="flex flex-col overflow-y-auto">
  {#each $categories as category}
    {@render CategorySection({ category })}
  {/each}
</div>

{#snippet CategorySection({ category }: { category: Category })}
  <div class="mb-8">
    <h1 class="text-primary mb-4 text-2xl font-bold">{category.name}</h1>
    <div class="grid grid-cols-1 gap-6 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4">
      {#each category.items as item}
        {@render ItemCard({ item })}
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
