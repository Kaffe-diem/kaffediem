<script>
  import { categories, itemsByCategory } from "$stores/menuStore";
  import { status } from "$stores/statusStore";
  import MenuItem from "$components/MenuItem.svelte";
</script>

{#each $categories as category (category.id)}
  {#if category.enabled}
    <div class="mb-10">
      <h1 class="text-primary mb-4 text-3xl">{category.name}</h1>
      <div class="grid grid-cols-2 gap-4 md:grid-cols-3 lg:grid-cols-4">
        {#each $itemsByCategory[category.id] ?? [] as item (item.id)}
          {#if item.enabled}
            <MenuItem {item} buyButton={$status.open} />
          {/if}
        {/each}
      </div>
    </div>
  {/if}
{/each}
