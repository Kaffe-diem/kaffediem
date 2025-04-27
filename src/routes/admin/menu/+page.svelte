<script lang="ts">
  import { categories, itemsByCategory } from "$stores/menuStore";
  import type { Category, Item } from "$lib/types";
</script>

<div class="flex flex-col gap-8 overflow-y-auto">
  <div class="flex flex-col gap-2">
    <a href="/admin/menu/customization" class="btn w-full">Endre tilpasninger</a>
    <a href="/admin/menu/item/new" class="btn w-full">Opprett et nytt produkt</a>
    <a href="/admin/menu/category/new" class="btn w-full">Opprett en ny kategori</a>
  </div>
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
      {#each $itemsByCategory[category.id] ?? [] as item}
        {@render ItemCard({ item })}
      {/each}
    </ul>
  </div>
{/snippet}

{#snippet ItemCard({ item }: { item: Item })}
  <li class="m-2 flex flex-row justify-between">
    <span>{item.name}</span>
    <div class="flex flex-row items-center gap-4">
      {#if !item.enabled}
        <span class="badge badge-soft badge-neutral">Deaktivert</span>
      {/if}
      <a href="/admin/menu/item/{item.id}" class="btn btn-neutral">Rediger</a>
    </div>
  </li>
{/snippet}
