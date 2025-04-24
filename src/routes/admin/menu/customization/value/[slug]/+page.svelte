<script lang="ts">
  // @ts-expect-error Is present, but lint fails
  import type { PageProps } from "./$types";
  import { customizationKeys, customizationValues } from "$stores/menuStore";
  import { CustomizationValue } from "$lib/types";
  import { goto } from "$app/navigation";

  let { data }: PageProps = $props();
  const id = data.id;
  const create = id == "new";

  let customizationName: string | undefined = $state();
  let customizationPrice: number | undefined = $state();
  let customizationKey: string | undefined = $state();
  $effect(() => {
    const value = $customizationValues.find((value) => value.id === id);
    if (value) {
      customizationName = value.name;
      customizationPrice = value.priceIncrementNok;
      customizationKey = value.belongsTo;
    }
  });

  function updateValue() {
    if (create) {
      customizationValues.create(
        new CustomizationValue(id, customizationName!, customizationPrice!, customizationKey!)
      );
    } else {
      customizationValues.update(
        new CustomizationValue(id, customizationName!, customizationPrice!, customizationKey!)
      );
    }
    goto("/admin/menu/customization");
  }
</script>

{#if create}
  <h1 class="text-center text-xl">Opprett en tilpasningskategori</h1>
  <div class="divider"></div>
{/if}
{#if customizationName || create}
  <div class="grid w-full grid-cols-2 gap-2">
    <div class="col-span-2">
      <fieldset class="fieldset">
        <legend class="fieldset-legend">Navn</legend>
        <input type="text" class="input w-full" bind:value={customizationName} placeholder="Navn" />
      </fieldset>
    </div>
    <div>
      <fieldset class="fieldset">
        <legend class="fieldset-legend">Prisendring (kr)</legend>
        <label class="input w-full">
          {#if customizationPrice >= 0}
            <span>+</span>
          {/if}
          <input
            type="number"
            class="input grow"
            bind:value={customizationPrice}
            placeholder="Prisendring"
          />
        </label>
      </fieldset>
    </div>
    <div>
      <fieldset class="fieldset">
        <legend class="fieldset-legend">Kategori</legend>
        <select class="select w-full" bind:value={customizationKey}>
          {#if customizationKey || create}
            <option disabled selected={create}>Velg en kategori</option>
            {#each $customizationKeys as category}
              <option value={category.id} selected={category.id == customizationKey}
                >{category.name}</option
              >
            {/each}
          {/if}
        </select>
      </fieldset>
    </div>
    <div class="divider col-span-2"></div>
    <div class="col-span-2">
      <button class="btn btn-primary w-full" onclick={updateValue}
        >{#if create}Opprett{:else}Lagre{/if}</button
      >
    </div>
  </div>
{:else}
  <div class="mx-30 grid grid-cols-1 gap-4">
    <h1 class="text-center text-xl">Kunne ikke finne tilpasning!</h1>
    <a href="/admin/menu/customization/value/new" rel="external" class="btn"
      >Opprett en ny tilpasning</a
    >
  </div>
{/if}
