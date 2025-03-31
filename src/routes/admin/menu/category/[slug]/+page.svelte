<script lang="ts">
  // @ts-expect-error Is present, but lint fails
  import type { PageProps } from "./$types";
  import { categories } from "$stores/menuStore";
  import { Category } from "$lib/types";
  import { goto } from "$app/navigation";

  let { data }: PageProps = $props();
  const id = data.id;

  let categoryName: string | undefined = $state();
  let categorySort: boolean | undefined = $state();
  let categoryEnabled: boolean | undefined = $state();
  $effect(() => {
    const category = $categories.find((category) => category.id === id);
    if (category) {
      categoryName = category.name;
      categorySort = category.sortOrder;
      categoryEnabled = category.enabled;
    }
  });

  function toggleState() {
    categoryEnabled = !categoryEnabled;
  }

  function updateCategory() {
    categories.update(new Category(id, categoryName, categorySort, categoryEnabled));
  }
</script>

{#if categoryName}
  <div class="grid w-full grid-cols-2 gap-2">
    <div class="col-span-2">
      <fieldset class="fieldset">
        <legend class="fieldset-legend">Navn</legend>
        <input
          type="text"
          class="input w-full"
          bind:value={categoryName}
          placeholder="Kategorinavn"
        />
      </fieldset>
    </div>
    <div>
      <fieldset class="fieldset">
        <legend class="fieldset-legend">Aktivert</legend>
        <button class="btn {categoryEnabled ? '' : 'btn-neutral'}" onclick={toggleState}
          >{#if categoryEnabled}Synlig{:else}Deaktivert{/if}</button
        >
      </fieldset>
    </div>
    <div>
      <fieldset class="fieldset">
        <legend class="fieldset-legend">Sortering (laveste først)</legend>
        <input
          type="number"
          class="input w-full"
          bind:value={categorySort}
          placeholder="Sorteringsrekkefølge"
        />
      </fieldset>
    </div>
    <div class="divider col-span-2"></div>
    <div class="col-span-2">
      <button class="btn btn-primary w-full" onclick={updateCategory}>Lagre</button>
    </div>
  </div>
{/if}
