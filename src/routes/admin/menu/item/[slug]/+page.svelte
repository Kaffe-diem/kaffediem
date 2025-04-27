<script lang="ts">
  // @ts-expect-error Is present, but lint fails
  import type { PageProps } from "./$types";
  import { items, categories } from "$stores/menuStore";
  import { Item } from "$lib/types";
  import { goto } from "$app/navigation";

  let { data }: PageProps = $props();
  const id = data.id;
  const create = id == "new";

  let itemName: string | undefined = $state();
  let itemPrice: number | undefined = $state();
  let itemCategory: string | undefined = $state();
  let itemImage: string | undefined = $state();
  let itemImageName: string | undefined = $state("");
  let itemEnabled: boolean | undefined = $state(true);
  $effect(() => {
    const item = $items.find((item) => item.id === id);
    if (item) {
      itemName = item.name;
      itemPrice = item.price;
      itemCategory = item.category;
      itemImage = item.image;
      itemImageName = item.imageName;
      itemEnabled = item.enabled;
    }
  });

  function toggleState() {
    itemEnabled = !itemEnabled;
  }

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
    if (create) {
      items.create(
        new Item(
          id,
          itemName!,
          itemPrice!,
          itemCategory!,
          itemImageName!,
          itemImage!,
          itemEnabled,
          imageFile
        )
      );
    } else {
      items.update(
        new Item(
          id,
          itemName!,
          itemPrice!,
          itemCategory!,
          itemImageName!,
          itemImage!,
          itemEnabled,
          imageFile
        )
      );
    }
    goto("/admin/menu");
  }
</script>

{#if create}
  <h1 class="text-center text-xl">Opprett et produkt</h1>
  <div class="divider"></div>
{/if}
{#if itemName || create}
  <div class="grid w-full grid-cols-2 gap-2">
    <div class="col-span-2">
      <fieldset class="fieldset">
        <legend class="fieldset-legend">Navn</legend>
        <input type="text" class="input w-full" bind:value={itemName} placeholder="Produktnavn" />
      </fieldset>
    </div>
    <div>
      <fieldset class="fieldset">
        <legend class="fieldset-legend">Pris</legend>
        <input type="number" class="input w-full" bind:value={itemPrice} placeholder="Pris" />
      </fieldset>
    </div>
    <div>
      <fieldset class="fieldset">
        <legend class="fieldset-legend">Kategori</legend>
        <select class="select w-full" bind:value={itemCategory}>
          {#if itemCategory || create}
            <option disabled selected={create}>Velg en kategori</option>
            {#each $categories as category}
              <option value={category.id} selected={category.id == itemCategory}
                >{category.name}</option
              >
            {/each}
          {/if}
        </select>
      </fieldset>
    </div>
    <div class="col-span-2">
      <fieldset class="fieldset">
        <legend class="fieldset-legend">Aktivert</legend>
        <button class="btn {itemEnabled ? '' : 'btn-neutral'}" onclick={toggleState}
          >{#if itemEnabled}Synlig{:else}Deaktivert{/if}</button
        >
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
      <fieldset class="fieldset w-full {itemImage ? 'col-span-1' : 'col-span-2'}">
        <legend class="fieldset-legend">Last opp et nytt bilde</legend>
        <input bind:files={imageFiles} type="file" class="file-input w-full" />
      </fieldset>
      {#if itemImage}
        <button onclick={deleteImage} class="btn btn-error h-full w-full">Slett bilde</button>
      {/if}
    </div>
    <div class="col-span-2">
      <button class="btn btn-primary w-full" onclick={updateItem}
        >{#if create}Opprett{:else}Lagre{/if}</button
      >
    </div>
  </div>
{:else}
  <div class="mx-30 grid grid-cols-1 gap-4">
    <h1 class="text-center text-xl">Kunne ikke finne produkt!</h1>
    <a href="/admin/menu/item/new" rel="external" class="btn">Opprett et nytt produkt</a>
  </div>
{/if}
