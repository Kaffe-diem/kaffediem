<script lang="ts">
  // @ts-expect-error Is present, but lint fails
  import type { PageProps } from "./$types";
  import { items, categories } from "$stores/menuStore";
  import { Item } from "$lib/types";
  import { goto } from "$app/navigation";

  import StateToggle from "$components/menu/StateToggle.svelte";
  import Input from "$components/menu/Input.svelte";

  let { data }: PageProps = $props();
  const id = data.id;
  const create = id == "new";

  let itemName: string | undefined = $state();
  let itemPrice: number | undefined = $state();
  let itemCategory: string | undefined = $state();
  let itemImage: string | undefined = $state();
  let itemImageName: string | undefined = $state("");
  let itemEnabled: boolean = $state(true);

  let exists: boolean = $state(false);

  $effect(() => {
    const item = $items.find((item) => item.id === id);
    if (item) {
      itemName = item.name;
      itemPrice = item.price;
      itemCategory = item.category;
      itemImage = item.image;
      itemImageName = item.imageName;
      itemEnabled = item.enabled;

      exists = true;
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

<h1 class="text-left text-2xl">
  {#if create}Opprett et produkt{:else}Rediger produkt{/if}
</h1>
<div class="divider"></div>
{#if exists || create}
  <form onsubmit={updateItem} class="grid w-full grid-cols-2 gap-2">
    <div class="col-span-2">
      <Input label="Navn" type="text" required placeholder="Produktnavn" bind:value={itemName} />
    </div>
    <div>
      <Input
        label="Pris"
        type="number"
        required
        min={1}
        placeholder="Pris"
        bind:value={itemPrice}
      />
    </div>
    <div>
      <fieldset class="fieldset">
        <legend class="fieldset-legend text-xl">Kategori</legend>
        <select class="select select-xl w-full" required bind:value={itemCategory}>
          {#if itemCategory || create}
            <option disabled value="" selected={create}>Velg en kategori</option>
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
      <StateToggle bind:state={itemEnabled} />
    </div>
    <div class="divider col-span-2"></div>
    <div class="col-span-2 grid grid-cols-2 gap-2">
      <div class="col-span-2 flex items-center justify-center">
        {#if itemImage}
          <img src={itemImage} alt="Bilde av {itemName}" class="max-h-96 w-auto rounded-xl" />
        {:else}
          <div class="text-xl">(Bilde mangler)</div>
        {/if}
      </div>
      <fieldset class="fieldset w-full {itemImage ? 'col-span-1' : 'col-span-2'}">
        <legend class="fieldset-legend text-xl">Last opp et nytt bilde</legend>
        <input bind:files={imageFiles} type="file" class="file-input file-input-xl w-full" />
      </fieldset>
      {#if itemImage}
        <button onclick={deleteImage} class="btn btn-error h-full w-full">Slett bilde</button>
      {/if}
    </div>
    <div class="divider col-span-2"></div>
    <div class="col-span-2">
      <button type="submit" class="btn btn-xl btn-primary w-full"
        >{#if create}Opprett{:else}Lagre{/if}</button
      >
    </div>
  </form>
{:else}
  <div class="mx-30 grid grid-cols-1 gap-4">
    <h1 class="text-center text-xl">Kunne ikke finne produkt!</h1>
    <a href="/admin/menu/item/new" rel="external" class="btn">Opprett et nytt produkt</a>
  </div>
{/if}
