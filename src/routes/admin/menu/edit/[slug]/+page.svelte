<script lang="ts">
  import type { PageProps } from "./$types";
  import { items, categories } from "$stores/menuStore";

  let { data }: PageProps = $props();
  const id = data.id;

  let itemName: string = $state();
  let itemPrice: number = $state();
  let itemCategory: string = $state();
  $effect(() => {
    const item = $items.find((item) => item.id === id);
    const category = $categories.find((category) => category.id == item.category);
    if (item) {
      itemName = item.name;
      itemPrice = item.price;
      itemCategory = category.id;
    }
  });

  function updateItem() {
    console.log(itemName, itemPrice, itemCategory);
  }
</script>

<div class="grid w-full grid-cols-2 gap-2">
  <div class="col-span-2">
    <fieldset class="fieldset">
      <legend class="fieldset-legend">Navn</legend>
      <input type="text" class="input w-full" bind:value={itemName} />
    </fieldset>
  </div>
  <div>
    <fieldset class="fieldset">
      <legend class="fieldset-legend">Pris</legend>
      <input type="number" class="input w-full" bind:value={itemPrice} />
    </fieldset>
  </div>
  <div>
    <fieldset class="fieldset">
      <legend class="fieldset-legend">Kategori</legend>
      <select class="select" bind:value={itemCategory}>
        {#if itemCategory}
          {#each $categories as category}
            <option value={category.id} selected={category.id == itemCategory.id}
              >{category.name}</option
            >
          {/each}
        {/if}
      </select>
    </fieldset>
  </div>
  <div class="col-span-2">
    <button class="btn btn-primary w-full" onclick={updateItem}>Lagre</button>
  </div>
</div>
