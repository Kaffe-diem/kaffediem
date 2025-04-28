<script lang="ts">
  // @ts-expect-error Is present, but lint fails
  import type { PageProps } from "./$types";
  import { categories } from "$stores/menuStore";
  import { Category } from "$lib/types";
  import { goto } from "$app/navigation";

  import StateToggle from "$components/menu/StateToggle.svelte";

  let { data }: PageProps = $props();
  const id = data.id;
  const create = id == "new";

  let categoryName: string | undefined = $state();
  let categorySort: number | undefined = $state();
  let categoryEnabled: boolean = $state(true);

  let exists: boolean = $state(false);

  $effect(() => {
    const category = $categories.find((category) => category.id === id);
    if (category) {
      categoryName = category.name;
      categorySort = category.sortOrder;
      categoryEnabled = category.enabled;

      exists = true;
    }
  });

  function updateCategory() {
    if (create) {
      categories.create(new Category(id, categoryName!, categorySort!, categoryEnabled));
    } else {
      categories.update(new Category(id, categoryName!, categorySort!, categoryEnabled));
    }
    goto("/admin/menu");
  }
</script>

{#if create}
  <h1 class="text-center text-xl">Opprett en kategori</h1>
  <div class="divider"></div>
{/if}
{#if exists}
  <form onsubmit={updateCategory} class="grid w-full grid-cols-2 gap-2">
    <h1 class="col-span-2 text-left text-2xl">Rediger kategori</h1>
    <div class="divider col-span-2"></div>
    <div class="col-span-2">
      <fieldset class="fieldset">
        <legend class="fieldset-legend">Navn</legend>
        <input
          type="text"
          class="input w-full"
          required
          bind:value={categoryName}
          placeholder="Kategorinavn"
        />
      </fieldset>
    </div>
    <div>
      <StateToggle bind:state={categoryEnabled} />
    </div>
    <div>
      <fieldset class="fieldset">
        <legend class="fieldset-legend">Sortering (laveste først)</legend>
        <input
          type="number"
          class="input w-full"
          required
          bind:value={categorySort}
          placeholder="Sorteringsrekkefølge"
        />
      </fieldset>
    </div>
    <div class="divider col-span-2"></div>
    <div class="col-span-2">
      <button type="submit" class="btn btn-primary w-full"
        >{#if create}Opprett{:else}Lagre{/if}</button
      >
    </div>
  </form>
{:else}
  <div class="mx-30 grid grid-cols-1 gap-4">
    <h1 class="text-center text-xl">Kunne ikke finne kategori!</h1>
    <a href="/admin/menu/category/new" rel="external" class="btn">Opprett en ny kategori</a>
  </div>
{/if}
