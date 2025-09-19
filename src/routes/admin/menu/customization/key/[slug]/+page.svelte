<script lang="ts">
  import { customizationKeys, customizationsByKey } from "$stores/menuStore";
  import { CustomizationKey } from "$lib/types";
  import { goto } from "$app/navigation";

  import StateToggle from "$components/menu/StateToggle.svelte";
  import Input from "$components/menu/Input.svelte";
  import { resolve } from "$app/paths";

  let { data } = $props();
  const id = data.id;
  const create = id == "new";

  let customizationName: string | undefined = $state();
  let customizationEnabled: boolean = $state(true);
  let customizationColor: string | undefined = $state("#CCCCCC");
  let customizationDefaultValue: string | undefined = $state();
  let customizationMultipleChoice: boolean = $state(false);

  let exists: boolean = $state(false);

  $effect(() => {
    const key = $customizationKeys.find((key) => key.id === id);
    if (key) {
      customizationName = key.name;
      customizationEnabled = key.enabled;
      customizationColor = key.labelColor;
      customizationDefaultValue = key.defaultValue;
      customizationMultipleChoice = key.multipleChoice;

      exists = true;
    }
  });

  function updateKey() {
    if (create) {
      customizationKeys.create(
        new CustomizationKey(
          id,
          customizationName!,
          customizationEnabled,
          customizationColor!,
          customizationDefaultValue!,
          customizationMultipleChoice
        )
      );
    } else {
      customizationKeys.update(
        new CustomizationKey(
          id,
          customizationName!,
          customizationEnabled,
          customizationColor!,
          customizationDefaultValue!,
          customizationMultipleChoice
        )
      );
    }
    goto(resolve("/admin/menu/customization"));
  }
</script>

<h1 class="text-left text-2xl">
  {#if create}Opprett en tilpasningskategori{:else}Rediger tilpasningskategori{/if}
</h1>
<div class="divider"></div>
{#if exists || create}
  <form onsubmit={updateKey} class="grid w-full grid-cols-2 gap-2">
    <div class="col-span-2">
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
    <div class="col-span-2">
      <fieldset class="fieldset">
        <legend class="fieldset-legend text-xl">Standard</legend>
        <select class="select select-xl w-full" bind:value={customizationDefaultValue}>
          <option value="">Ingen</option>
          {#each $customizationsByKey[id] ?? [] as customization (customization.id)}
            <option value={customization.id}>
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
    <div class="divider col-span-2"></div>
    <div class="col-span-2">
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
