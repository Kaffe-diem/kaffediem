<script lang="ts">
  // @ts-expect-error Is present, but lint fails
  import type { PageProps } from "./$types";
  import { categories } from "$stores/menuStore";
  import { Category } from "$lib/types";
  import { goto } from "$app/navigation";

  import StateToggle from "$components/menu/StateToggle.svelte";
  import Input from "$components/menu/Input.svelte";

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

<h1 class="text-left text-2xl">
  {#if create}Opprett en kategori{:else}Rediger kategori{/if}
</h1>
<div class="divider"></div>
{#if exists || create}
  <form onsubmit={updateCategory} class="grid w-full grid-cols-2 gap-2">
    <div class="col-span-2">
      <Input
        label="Navn"
        type="text"
        required
        bind:value={categoryName}
        placeholder="Kategorinavn"
      />
    </div>
    <div>
      <StateToggle bind:state={categoryEnabled} />
    </div>
    <div>
      <Input
        label="Sortering (laveste først)"
        type="number"
        required
        bind:value={categorySort}
        placeholder="Sorteringsrekkefølge"
      />
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
    <h1 class="text-center text-xl">Kunne ikke finne kategori!</h1>
    <a href="/admin/menu/category/new" rel="external" class="btn">Opprett en ny kategori</a>
  </div>
{/if}
