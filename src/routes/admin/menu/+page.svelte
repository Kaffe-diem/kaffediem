<script lang="ts">
  import { categories } from "$stores/menuStore";
  import type { Category, Item } from "$lib/types";
</script>

<div class="flex flex-col gap-8 overflow-y-auto">
  <a href="/admin/menu/item/new" class="btn w-full">Opprett et nytt produkt</a>
  {#each $categories as category}
    {@render CategorySection({ category })}
  {/each}
</div>

{#snippet CategorySection({ category }: { category: Category })}
  <div>
    <div class="mb-4 flex flex-row items-center justify-between px-2">
      <span class="text-2xl">{category.name}</span>
      <div class="flex flex-row items-center gap-4">
        {#if !category.enabled}
          <span class="badge badge-soft badge-neutral">Deaktivert</span>
        {/if}
        <a href="/admin/menu/category/{category.id}" class="btn">Rediger</a>
      </div>
    </div>
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
    <a href="/admin/menu/item/{item.id}" class="btn btn-neutral">Rediger</a>
  </li>
{/snippet}
