<script lang="ts">
  import { menuIndexes, createCustomizationKey, updateCustomizationKey } from "$stores/menu";
  import type { CustomizationKey } from "$lib/types";
  import { goto } from "$app/navigation";

  import StateToggle from "$components/menu/StateToggle.svelte";
  import Input from "$components/menu/Input.svelte";
  import { resolve } from "$app/paths";

  let { data } = $props();
  const id = data.id;
  const create = id == "new";
  const numericId = create ? undefined : Number(id);
  let customizationName: string | undefined = $state();
  let customizationEnabled: boolean = $state(true);
  let customizationColor: string | undefined = $state("#CCCCCC");
  let customizationDefaultValue: string | undefined = $state();
  let customizationMultipleChoice: boolean = $state(false);
  let customizationSort: number = $state(0);

  let exists: boolean = $state(false);

  $effect(() => {
    const key = $menuIndexes.customization_keys.find((key) => key.id === numericId);
    if (key) {
      customizationName = key.name;
      customizationEnabled = key.enable;
      customizationColor = key.label_color ?? "#CCCCCC";
      customizationDefaultValue = key.default_value ?? "";
      customizationMultipleChoice = key.multiple_choice;
      customizationSort = key.sort_order;

      exists = true;
    }
  });

  async function handleSubmit(event: SubmitEvent) {
    event.preventDefault();

    if (!customizationName) return;

    const payload: CustomizationKey = {
      id: create ? 0 : Number(id),
      name: customizationName,
      enable: customizationEnabled,
      label_color: customizationColor ?? "",
      default_value: customizationDefaultValue ?? "",
      multiple_choice: customizationMultipleChoice,
      sort_order: customizationSort
    };

    if (create) {
      await createCustomizationKey(payload);
    } else {
      await updateCustomizationKey({ ...payload, id: Number(id) });
    }
    goto(resolve("/admin/menu/customization"));
  }
</script>

<h1 class="text-left text-2xl">
  {#if create}Opprett en tilpasningskategori{:else}Rediger tilpasningskategori{/if}
</h1>
<div class="divider"></div>
{#if exists || create}
  <form onsubmit={handleSubmit} class="grid w-full grid-cols-3 gap-2">
    <div class="col-span-full">
      <Input
        label="Navn"
        type="text"
        required
        placeholder="Kategorinavn"
        bind:value={customizationName}
      />
    </div>
    <div>
      <StateToggle bind:state={customizationEnabled} />
    </div>
    <div>
      <Input label="Farge" type="color" bind:value={customizationColor} />
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
      <fieldset class="fieldset">
        <legend class="fieldset-legend text-xl">Standard</legend>
        <select class="select select-xl w-full" bind:value={customizationDefaultValue}>
          <option value="">Ingen</option>
          {#each $menuIndexes.customizations_by_key[numericId ?? -1] ?? [] as customization (customization.id)}
            <option
              value={String(customization.id)}
              selected={String(customization.id) === customizationDefaultValue}
            >
              {customization.name}
            </option>
          {/each}
        </select>
      </fieldset>
    </div>
    <label class="mt-4">
      <span class="text-xl font-bold">Flervalg</span>
      <input
        type="checkbox"
        class="checkbox checkbox-xl ml-4"
        bind:checked={customizationMultipleChoice}
      />
    </label>
    <div class="divider col-span-full"></div>
    <div class="col-span-full">
      <button type="submit" class="btn btn-xl btn-primary w-full"
        >{#if create}Opprett{:else}Lagre{/if}</button
      >
    </div>
  </form>
{:else}
  <div class="mx-30 grid grid-cols-1 gap-4">
    <h1 class="text-center text-xl">Kunne ikke finne tilpasningskategori!</h1>
    <a href={resolve("/admin/menu/customization/key/new")} rel="external" class="btn"
      >Opprett en ny tilpasningskategori</a
    >
  </div>
{/if}
