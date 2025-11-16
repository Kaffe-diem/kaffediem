<script lang="ts">
  import { menuIndexes, createCategory, updateCategory } from "$stores/menu";
  import type { Category } from "$lib/types";
  import { goto } from "$app/navigation";

  import StateToggle from "$components/menu/StateToggle.svelte";
  import Input from "$components/menu/Input.svelte";
  import { resolve } from "$app/paths";

  let { data } = $props();
  const id = data.id;
  const create = id === "new";
  const numericId = create ? undefined : Number(id);
  const category = $derived($menuIndexes.categories.find((category) => category.id === numericId));

  let categoryName: string | undefined = $state();
  let categorySort: number | undefined = $state();
  let categoryEnabled: boolean = $state(true);
  let categoryValidCustomizations: number[] = $state([]);

  let exists: boolean = $state(false);

  $effect(() => {
    if (category) {
      categoryName = category.name;
      categorySort = category.sort_order;
      categoryEnabled = category.enable;
      categoryValidCustomizations = category.valid_customizations;

      exists = true;
    }
  });

  async function handleSubmit(event: SubmitEvent) {
    event.preventDefault();

    if (!categoryName || categorySort === undefined) return;

    const payload: Category = {
      id: create ? 0 : Number(id),
      name: categoryName,
      sort_order: categorySort,
      enable: categoryEnabled,
      valid_customizations: categoryValidCustomizations
    };

    if (create) {
      await createCategory(payload);
    } else {
      await updateCategory({ ...payload, id: numericId! });
    }
    goto(resolve("/admin/menu"));
  }
</script>

<h1 class="text-left text-2xl">
  {#if create}Opprett en kategori{:else}Rediger kategori{/if}
</h1>
<div class="divider"></div>
{#if exists || create}
  <form onsubmit={handleSubmit} class="grid w-full grid-cols-2 gap-2">
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
        {#each $menuIndexes.customization_keys as customizationKey (customizationKey.id)}
          <li class="my-6">
            <label class="grid grid-cols-[1fr_1fr]">
              <span class="text-xl">{customizationKey.name}</span>
              <input
                type="checkbox"
                checked={categoryValidCustomizations.includes(customizationKey.id)}
                class="checkbox checkbox-xl"
                onchange={(event) => {
                  if (event.currentTarget.checked) {
                    if (!categoryValidCustomizations.includes(customizationKey.id)) {
                      categoryValidCustomizations = [
                        ...categoryValidCustomizations,
                        customizationKey.id
                      ];
                    }
                  } else {
                    categoryValidCustomizations = categoryValidCustomizations.filter(
                      (selectedId) => selectedId !== customizationKey.id
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
