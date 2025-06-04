<script lang="ts">
  // @ts-expect-error Is present, but lint fails
  import type { PageProps } from "./$types";
  import { customizationKeys, customizationValues } from "$stores/menuStore";
  import { CustomizationValue } from "$lib/types";
  import { goto } from "$app/navigation";

  import StateToggle from "$components/menu/StateToggle.svelte";
  import Input from "$components/menu/Input.svelte";

  let { data }: PageProps = $props();
  const id = data.id;
  const create = id == "new";

  let customizationName: string | undefined = $state();
  let customizationPrice: number = $state(0);
  let customizationKey: string | undefined = $state();
  let customizationEnabled: boolean = $state(true);

  let exists: boolean = $state(true);

  $effect(() => {
    const value = $customizationValues.find((value) => value.id === id);
    if (value) {
      customizationName = value.name;
      customizationPrice = value.priceIncrementNok;
      customizationKey = value.belongsTo;
      customizationEnabled = value.enabled;

      exists = true;
    }
  });

  function updateValue() {
    if (create) {
      customizationValues.create(
        new CustomizationValue(
          id,
          customizationName!,
          customizationPrice!,
          customizationKey!,
          customizationEnabled
        )
      );
    } else {
      customizationValues.update(
        new CustomizationValue(
          id,
          customizationName!,
          customizationPrice!,
          customizationKey!,
          customizationEnabled
        )
      );
    }
    goto("/admin/menu/customization");
  }
</script>

<h1 class="text-left text-2xl">
  {#if create}Opprett en tilpasning{:else}Rediger tilpasning{/if}
</h1>
<div class="divider"></div>
{#if exists || create}
  <form onsubmit={updateValue} class="grid w-full grid-cols-2 gap-2">
    <div class="col-span-2">
      <Input
        label="Navn"
        type="text"
        required
        placeholder="Tilpasningnavn"
        bind:value={customizationName}
      />
    </div>
    <div>
      <fieldset class="fieldset">
        <legend class="fieldset-legend text-xl">Prisendring (kr)</legend>
        <label class="input input-xl w-full">
          {#if customizationPrice >= 0}
            <span>+</span>
          {/if}
          <input
            type="number"
            class="input input-xl grow"
            required
            bind:value={customizationPrice}
            placeholder="Prisendring"
          />
        </label>
      </fieldset>
    </div>
    <div>
      <fieldset class="fieldset">
        <legend class="fieldset-legend text-xl">Kategori</legend>
        <select class="select select-xl w-full" required bind:value={customizationKey}>
          {#if customizationKey || create}
            <option disabled value="" selected={create}>Velg en kategori</option>
            {#each $customizationKeys as category}
              <option value={category.id} selected={category.id == customizationKey}
                >{category.name}</option
              >
            {/each}
          {/if}
        </select>
      </fieldset>
    </div>
    <div class="col-span-2">
      <StateToggle bind:state={customizationEnabled} />
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
    <h1 class="text-center text-xl">Kunne ikke finne tilpasning!</h1>
    <a href="/admin/menu/customization/value/new" rel="external" class="btn"
      >Opprett en ny tilpasning</a
    >
  </div>
{/if}
