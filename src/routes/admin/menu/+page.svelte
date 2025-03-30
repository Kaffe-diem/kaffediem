<script lang="ts">
  import { categories } from "$stores/menuStore";
  import type { Category, Item } from "$lib/types";
</script>

<div class="flex flex-col overflow-y-auto">
  {#each $categories as category}
    {@render CategorySection({ category })}
  {/each}
</div>

{#snippet CategorySection({ category }: { category: Category })}
  <h2 class="text-2xl">{category.name}</h2>
  <ul class="mb-8 list-none">
    {#each category.items as item}
      {@render ItemCard({ item })}
    {/each}
  </ul>
{/snippet}

{#snippet ItemCard({ item }: { item: Item })}
  <li class="m-2 flex flex-row justify-between">
    <span>{item.name}</span>
    <a href="/admin/menu/edit/{item.id}" class="btn btn-neutral">Rediger</a>
  </li>
{/snippet}
