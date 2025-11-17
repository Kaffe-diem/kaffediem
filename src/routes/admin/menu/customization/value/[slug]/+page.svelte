<script lang="ts">
  import { menuIndexes, createCustomizationValue, updateCustomizationValue } from "$stores/menu";
  import type { CustomizationValue } from "$lib/types";
  import { goto } from "$app/navigation";

  import StateToggle from "$components/menu/StateToggle.svelte";
  import Input from "$components/menu/Input.svelte";
  import { resolve } from "$app/paths";

  let { data } = $props();
  const id = data.id;
  const create = id == "new";
  const numericId = create ? undefined : Number(id);

  let customizationName: string | undefined = $state();
  let customizationPrice: number = $state(0);
  let customizationConstantPrice: boolean = $state(true);
  let customizationKey: string | undefined = $state();
  let customizationEnabled: boolean = $state(true);
  let customizationSort: number = $state(0);

  let exists: boolean = $state(true);

  $effect(() => {
    const value = $menuIndexes.customization_values.find((value) => value.id === numericId);
    if (value) {
      customizationName = value.name;
      customizationPrice = value.price_increment_nok;
      customizationConstantPrice = value.constant_price;
      customizationKey = String(value.belongs_to);
      customizationEnabled = value.enable;
      customizationSort = value.sort_order;

      exists = true;
    }
  });

  async function handleSubmit(event: SubmitEvent) {
    event.preventDefault();

    if (!customizationName || customizationKey === undefined) return;

    const payload: CustomizationValue = {
      id: create ? 0 : (numericId ?? 0),
      name: customizationName,
      price_increment_nok: customizationPrice,
      constant_price: customizationConstantPrice,
      belongs_to: Number(customizationKey),
      enable: customizationEnabled,
      sort_order: customizationSort
    };

    if (create) {
      await createCustomizationValue(payload);
    } else {
      await updateCustomizationValue({ ...payload, id: numericId ?? 0 });
    }
    goto(resolve("/admin/menu/customization"));
  }

  function handlePriceChangeType() {
    customizationConstantPrice = !customizationConstantPrice;
  }
</script>

<h1 class="text-left text-2xl">
  {#if create}Opprett en tilpasning{:else}Rediger tilpasning{/if}
</h1>
<div class="divider"></div>
{#if exists || create}
  <form onsubmit={handleSubmit} class="grid w-full grid-cols-3 gap-2">
    <div class="col-span-full">
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
        <legend class="fieldset-legend text-xl"
          >Prisendring {#if customizationConstantPrice}(kr){:else}(%){/if}</legend
        >
        <label class="input input-xl w-full">
          {#if customizationPrice >= 0 && customizationConstantPrice}
            <span>+</span>
          {/if}
          <input
            type="number"
            class="input input-xl peer grow"
            required
            bind:value={customizationPrice}
            placeholder="Prisendring"
          />
          <button type="button" class="btn" onclick={handlePriceChangeType}
            >{#if customizationConstantPrice}+/-{:else}%{/if}</button
          >
        </label>
      </fieldset>
    </div>
    <div>
      <fieldset class="fieldset">
        <legend class="fieldset-legend text-xl">Kategori</legend>
        <select class="select select-xl w-full" required bind:value={customizationKey}>
          {#if customizationKey || create}
            <option disabled value="" selected={create}>Velg en kategori</option>
            {#each $menuIndexes.customization_keys as category (category.id)}
              <option
                value={String(category.id)}
                selected={String(category.id) === customizationKey}>{category.name}</option
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
        bind:value={customizationSort}
        placeholder="Sorteringsrekkefølge"
      />
    </div>
    <div class="col-span-full">
      <StateToggle bind:state={customizationEnabled} />
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
    <h1 class="text-center text-xl">Kunne ikke finne tilpasning!</h1>
    <a href={resolve("/admin/menu/customization/value/new")} rel="external" class="btn"
      >Opprett en ny tilpasning</a
    >
  </div>
{/if}
