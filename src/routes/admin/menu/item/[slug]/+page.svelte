<script lang="ts">
  import { menuIndexes, createItem, updateItem } from "$stores/menu";
  import type { Item } from "$lib/types";
  import { goto } from "$app/navigation";

  import StateToggle from "$components/menu/StateToggle.svelte";
  import Input from "$components/menu/Input.svelte";
  import { resolve } from "$app/paths";

  let { data } = $props();
  const id = data.id;
  const create = id == "new";

  let itemName: string | undefined = $state();
  let itemPrice: number | undefined = $state();
  let itemCategory: string | undefined = $state();
  let itemImage: string | null | undefined = $state();
  let itemEnabled: boolean = $state(true);
  let itemSort: number = $state(0);

  let exists: boolean = $state(false);

  $effect(() => {
    const item = $menuIndexes.items.find((item) => item.id === id);
    if (item) {
      itemName = item.name;
      itemPrice = item.price_nok;
      itemCategory = item.category;
      itemImage = item.image;
      itemEnabled = item.enable;
      itemSort = item.sort_order;

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
      imageFile = null;
    }
  }

  async function handleSubmit(event: SubmitEvent) {
    event.preventDefault();

    if (!itemName || itemPrice === undefined || !itemCategory) return;

    const payload: Item = {
      id: create ? "" : id,
      name: itemName,
      price_nok: itemPrice,
      category: itemCategory,
      image: itemImage ?? "",
      enable: itemEnabled,
      sort_order: itemSort,
      imageFile: imageFile ?? undefined
    };

    if (!payload.imageFile) {
      delete payload.imageFile;
    }

    if (create) {
      await createItem(payload);
    } else {
      await updateItem({ ...payload, id });
    }
    goto(resolve("/admin/menu"));
  }
</script>

<h1 class="text-left text-2xl">
  {#if create}Opprett et produkt{:else}Rediger produkt{/if}
</h1>
<div class="divider"></div>
{#if exists || create}
  <form onsubmit={handleSubmit} class="grid w-full grid-cols-3 gap-2">
    <div class="col-span-full">
      <Input label="Navn" type="text" required placeholder="Produktnavn" bind:value={itemName!} />
    </div>
    <div>
      <Input
        label="Pris"
        type="number"
        required
        min={1}
        placeholder="Pris"
        bind:value={itemPrice!}
      />
    </div>
    <div>
      <fieldset class="fieldset">
        <legend class="fieldset-legend text-xl">Kategori</legend>
        <select class="select select-xl w-full" required bind:value={itemCategory}>
          {#if itemCategory || create}
            <option disabled value="" selected={create}>Velg en kategori</option>
            {#each $menuIndexes.categories as category (category.id)}
              <option value={category.id} selected={category.id == itemCategory}
                >{category.name}</option
              >
            {/each}
          {/if}
        </select>
      </fieldset>
    </div>
    <div>
      <Input
        label="Sortering (laveste først)"
        type="number"
        required
        bind:value={itemSort}
        placeholder="Sorteringsrekkefølge"
      />
    </div>
    <div class="col-span-full">
      <StateToggle bind:state={itemEnabled} />
    </div>
    <div class="divider col-span-full"></div>
    <div class="col-span-full grid grid-cols-2 gap-2">
      <div class="col-span-full flex items-center justify-center">
        {#if itemImage}
          <img src={itemImage} alt="Bilde av {itemName}" class="max-h-96 w-auto rounded-xl" />
        {:else}
          <div class="text-xl">(Bilde mangler)</div>
        {/if}
      </div>
      <fieldset class="fieldset w-full {itemImage ? 'col-span-1' : 'col-span-full'}">
        <legend class="fieldset-legend text-xl">Last opp et nytt bilde</legend>
        <input bind:files={imageFiles} type="file" class="file-input file-input-xl w-full" />
      </fieldset>
      {#if itemImage}
        <button onclick={deleteImage} class="btn btn-error h-full w-full">Slett bilde</button>
      {/if}
    </div>
    <div class="divider col-span-full"></div>
    <div class="col-span-full">
      <button type="submit" class="btn btn-xl btn-primary w-full"
        >{#if create}Opprett{:else}Lagre{/if}</button
      >
    </div>
  </form>
{:else}
  <div class="mx-30 grid grid-cols-1 gap-4">
    <h1 class="text-center text-xl">Kunne ikke finne produkt!</h1>
    <a href={resolve("/admin/menu/item/new")} rel="external" class="btn">Opprett et nytt produkt</a>
  </div>
{/if}
