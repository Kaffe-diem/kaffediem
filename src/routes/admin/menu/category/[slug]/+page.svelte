<script lang="ts">
  import { categories } from "$stores/menuStore";
  import { Category } from "$lib/types";
  import { goto } from "$app/navigation";
  import { customizationKeys } from "$stores/menuStore";

  import StateToggle from "$components/menu/StateToggle.svelte";
  import Input from "$components/menu/Input.svelte";
  import { resolve } from "$app/paths";

  let { data } = $props();
  const id = data.id;
  const create = id == "new";
  const category = $categories.find((category) => category.id === id);

  let categoryName: string | undefined = $state();
  let categorySort: number | undefined = $state();
  let categoryEnabled: boolean = $state(true);
  let categoryValidCustomizationKeys: string[] | undefined = $state();

  let exists: boolean = $state(false);

  $effect(() => {
    if (category) {
      categoryName = category.name;
      categorySort = category.sortOrder;
      categoryEnabled = category.enabled;
      categoryValidCustomizationKeys = category.customizationKeys;

      exists = true;
    }
  });

  function updateCategory() {
    if (create) {
      categories.create(
        new Category(
          id,
          categoryName!,
          categorySort!,
          categoryEnabled,
          categoryValidCustomizationKeys!
        )
      );
    } else {
      categories.update(
        new Category(
          id,
          categoryName!,
          categorySort!,
          categoryEnabled,
          categoryValidCustomizationKeys!
        )
      );
    }
    goto(resolve("/admin/menu"));
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
        bind:value={categoryName!}
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
        bind:value={categorySort!}
        placeholder="Sorteringsrekkefølge"
      />
    </div>
    <fieldset class="fieldset">
      <legend class="fieldset-legend text-xl">Tilpasninger</legend>
      <ul class="list-none">
        {#each $customizationKeys as customizationKey (customizationKey.id)}
          <li class="my-6">
            <label class="grid grid-cols-[1fr_1fr]">
              <span class="text-xl">{customizationKey.name}</span>
              <input
                type="checkbox"
                checked={categoryValidCustomizationKeys?.includes(customizationKey.id)}
                class="checkbox checkbox-xl"
                onchange={(event) => {
                  if (event.currentTarget.checked) {
                    if (!categoryValidCustomizationKeys?.includes(customizationKey.id)) {
                      categoryValidCustomizationKeys = [
                        ...(categoryValidCustomizationKeys ?? []),
                        customizationKey.id
                      ];
                    }
                  } else {
                    categoryValidCustomizationKeys = categoryValidCustomizationKeys?.filter(
                      (id) => id !== customizationKey.id
                    );
                  }
                }}
              />
            </label>
          </li>
        {/each}
      </ul>
    </fieldset>
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
    <a href={resolve("/admin/menu/category/new")} rel="external" class="btn"
      >Opprett en ny kategori</a
    >
  </div>
{/if}
