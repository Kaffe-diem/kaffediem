<script lang="ts">
  // @ts-expect-error Is present, but lint fails
  import type { PageProps } from "./$types";
  import { items, categories } from "$stores/menuStore";
  import { Item } from "$lib/types";

  let { data }: PageProps = $props();
  const id = data.id;

  let itemName: string | undefined = $state();
  let itemPrice: number | undefined = $state();
  let itemCategory: string | undefined = $state();
  let itemImage: string | undefined = $state();
  let itemImageName: string | undefined = $state();
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

  let imageFiles: FileList | null | undefined = $state();
  let imageFile: File | null = null;
  $effect(() => {
    if (imageFiles) {
      imageFile = imageFiles[0]!;
      const reader = new FileReader();
      reader.onload = () => {
        itemImage = reader.result as string;
      };
      reader.readAsDataURL(imageFile as Blob);
    }
  });

  function deleteImage() {
    if (window.confirm("Er du sikker på at du vil slette bildet?")) {
      itemImage = undefined;
      itemImageName = "";
      imageFile = null;
    }
  }

  function updateItem() {
    items.update(
      new Item(id, itemName!, itemPrice!, itemCategory!, itemImageName!, itemImage!, imageFile)
    );
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
            <option value={category.id} selected={category.id == itemCategory}
              >{category.name}</option
            >
          {/each}
        {/if}
      </select>
    </fieldset>
  </div>
  <div class="divider col-span-2"></div>
  <div class="col-span-2 grid grid-cols-2 gap-2">
    <div class="col-span-2 flex items-center justify-center">
      {#if itemImage}
        <img src={itemImage} alt="Bilde av {itemName}" class="max-h-96 w-auto rounded-xl" />
      {:else}
        (Bilde mangler)
      {/if}
    </div>
    <fieldset class="fieldset">
      <legend class="fieldset-legend">Last opp et nytt bilde</legend>
      <input bind:files={imageFiles} type="file" class="file-input w-full" />
    </fieldset>
    <button onclick={deleteImage} class="btn btn-error h-full">Slett bilde</button>
  </div>
  <div class="col-span-2">
    <button class="btn btn-primary w-full" onclick={updateItem}>Lagre</button>
  </div>
</div>
