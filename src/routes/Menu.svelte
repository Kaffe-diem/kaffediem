<script>
  import { menuIndexes } from "$stores/menu";
  import { status } from "$stores/status";
  import MenuItem from "$components/MenuItem.svelte";
</script>

{#each $menuIndexes.categories as category (category.id)}
  {#if category.enable}
    <div class="mb-10">
      <h1 class="text-primary mb-4 text-3xl">{category.name}</h1>
      <div class="grid grid-cols-2 gap-4 md:grid-cols-3 lg:grid-cols-4">
        {#each $menuIndexes.items_by_category[category.id] ?? [] as item (item.id)}
          {#if item.enable}
            <MenuItem {item} buyButton={$status.open} />
          {/if}
        {/each}
      </div>
    </div>
  {/if}
{/each}
