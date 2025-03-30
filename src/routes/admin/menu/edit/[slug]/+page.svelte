<script lang="ts">
  import { onMount } from "svelte";
  import type { PageProps } from "./$types";
  import { items, categories } from "$stores/menuStore";
  import { get, derived } from "svelte/store";

  let { data }: PageProps = $props();
  const id = data.id;

  // const item = $items.find((item) => item.id === id);
  // const category = $categories.find((category) => category.id == item.category)

  const item = derived(items, ($items) => $items.find((item) => item.id === id));

  const item_category = derived(categories, ($categories) =>
    $categories.find((category) => category.id == $item.category)
  );

  let itemName: string = $state();
  let itemPrice: number = $state();
  let itemCategory: string = $state();
  $effect(() => {
    if ($item) {
      itemName = $item.name;
      itemPrice = $item.price;
      itemCategory = $item.category;
    }
  });

  function updateItem() {
    console.log(itemName, itemPrice, itemCategory);
  }
</script>

<div class="grid w-full grid-cols-2 gap-2">
  {#if $item}
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
          {#if $item_category}
            {#each $categories as category}
              <option value={category.id} selected={category.id == $item_category.id}
                >{category.name}</option
              >
            {/each}
          {/if}
        </select>
      </fieldset>
    </div>
  {/if}
  <div class="col-span-2">
    <button class="btn btn-primary w-full" onclick={updateItem}>Lagre</button>
  </div>
</div>
