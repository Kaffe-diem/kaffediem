<script lang="ts">
  import { categories } from "$stores/menuStore";
  import type { Category, Item } from "$lib/types";
</script>

<div class="flex flex-col gap-8 overflow-y-auto">
  <a href="/admin/menu/edit/new" class="btn w-full">Opprett et nytt produkt</a>
  {#each $categories as category}
    {@render CategorySection({ category })}
  {/each}
</div>

{#snippet CategorySection({ category }: { category: Category })}
  <div>
    <h2 class="mb-4 text-2xl">{category.name}</h2>
    <ul class="list-none">
      {#each category.items as item}
        {@render ItemCard({ item })}
      {/each}
    </ul>
  </div>
{/snippet}

{#snippet ItemCard({ item }: { item: Item })}
  <li class="m-2 flex flex-row justify-between">
    <span>{item.name}</span>
    <a href="/admin/menu/edit/{item.id}" class="btn btn-neutral">Rediger</a>
  </li>
{/snippet}
