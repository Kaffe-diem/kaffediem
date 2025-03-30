<script lang="ts">
  import type { PageProps } from "./$types";
  import { items, categories } from "$stores/menuStore";
  import { Item } from "$lib/types";
  import pb from "$lib/pocketbase";

  let { data }: PageProps = $props();
  const id = data.id;

  let itemName: string = $state();
  let itemPrice: number = $state();
  let itemCategory: string = $state();
  let itemImage: string = $state();
  let itemImageName: string = $state();
  $effect(() => {
    const item = $items.find((item) => item.id === id);
    if (item) {
      itemName = item.name;
      itemPrice = item.price;
      itemCategory = item.category;
      itemImage = item.image;
      itemImageName = item.imageName;
    }
  });

  function updateImage() {
    const file = event.target.files[0];
    if (file) {
      const reader = new FileReader();
      reader.onload = () => {
        itemImage = reader.result;
      };
      reader.readAsDataURL(file);
    }
  }

  function updateItem() {
    items.update(new Item(id, itemName, itemPrice, itemCategory, itemImageName, itemImage));
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
  <div class="divider col-span-2"></div>
  <div class="col-span-2 flex flex-col gap-2">
    {#if itemImage}
      <div class="flex items-center justify-center">
        <img src={itemImage} alt="Bilde av {itemName}" class="max-h-96 w-auto rounded-xl" />
      </div>
    {:else}
      (Bilde mangler)
    {/if}
    <fieldset class="fieldset">
      <legend class="fieldset-legend">Last opp et nytt bilde</legend>
      <input onchange={updateImage} type="file" class="file-input w-full" />
    </fieldset>
  </div>
  <div class="col-span-2">
    <button class="btn btn-primary w-full" onclick={updateItem}>Lagre</button>
  </div>
</div>
