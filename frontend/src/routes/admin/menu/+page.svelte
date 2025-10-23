<script lang="ts">
  import { categories, itemsByCategory } from "$stores/menu";
  import type { Category, Item } from "$lib/types";
  import { resolve } from "$app/paths";
</script>

<h1 class="mb-8 text-3xl">Meny</h1>

<div class="flex flex-col gap-8 overflow-y-auto">
  <div class="flex flex-col gap-2">
    <a href={resolve("/admin/menu/customization")} class="btn btn-lg btn-neutral w-full"
      >Rediger tilpasninger</a
    >
    <a href={resolve("/admin/menu/category/new")} class="btn btn-lg w-full"
      >Opprett en ny kategori</a
    >
    <a href={resolve("/admin/menu/item/new")} class="btn btn-lg w-full">Opprett et nytt produkt</a>
  </div>
  {#each $categories as category (category.id)}
    {@render CategorySection({ category })}
  {/each}
</div>

{#snippet CategorySection({ category }: { category: Category })}
  <div>
    <div class="mb-4 flex flex-row items-center justify-between px-2">
      <span class="text-3xl">{category.name}</span>
      <div class="flex flex-row items-center gap-4">
        {#if !category.enabled}
          <span class="badge badge-xl badge-soft badge-neutral italic">Deaktivert</span>
        {/if}
        <a href={resolve(`/admin/menu/category/${category.id}`)} class="btn btn-lg btn-neutral"
          >Rediger</a
        >
      </div>
    </div>
    <ul class="list-none">
      {#each $itemsByCategory[category.id] ?? [] as item (item.id)}
        {@render ItemCard({ item })}
      {/each}
    </ul>
  </div>
{/snippet}

{#snippet ItemCard({ item }: { item: Item })}
  <li class="m-2 flex flex-row justify-between">
    <span class="text-xl">{item.name}</span>
    <div class="flex flex-row items-center gap-4">
      {#if !item.enabled}
        <span class="badge badge-xl badge-soft badge-neutral">Deaktivert</span>
      {/if}
      <a href={resolve(`/admin/menu/item/${item.id}`)} class="btn btn-lg">Rediger</a>
    </div>
  </li>
{/snippet}
