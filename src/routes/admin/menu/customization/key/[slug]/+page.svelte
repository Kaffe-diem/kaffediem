<script lang="ts">
  // @ts-expect-error Is present, but lint fails
  import type { PageProps } from "./$types";
  import { customizationKeys } from "$stores/menuStore";
  import { CustomizationKey } from "$lib/types";
  import { goto } from "$app/navigation";

  let { data }: PageProps = $props();
  const id = data.id;
  const create = id == "new";

  let customizationName: string | undefined = $state();
  let customizationEnabled: boolean | undefined = $state(true);
  let customizationColor: string | undefined = $state("#CCCCCC");
  $effect(() => {
    const key = $customizationKeys.find((key) => key.id === id);
    if (key) {
      customizationName = key.name;
      customizationEnabled = key.enabled;
      customizationColor = key.labelColor;
    }
  });

  function toggleState() {
    customizationEnabled = !customizationEnabled;
  }

  function updateKey() {
    if (create) {
      customizationKeys.create(
        new CustomizationKey(id, customizationName!, customizationEnabled!, customizationColor!)
      );
    } else {
      customizationKeys.update(
        new CustomizationKey(id, customizationName!, customizationEnabled!, customizationColor!)
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
        <legend class="fieldset-legend">Farge</legend>
        <input type="color" class="input w-full" bind:value={customizationColor} />
      </fieldset>
    </div>
    <div>
      <fieldset class="fieldset">
        <legend class="fieldset-legend">Aktivert</legend>
        <button class="btn {customizationEnabled ? '' : 'btn-neutral'}" onclick={toggleState}
          >{#if customizationEnabled}Synlig{:else}Deaktivert{/if}</button
        >
      </fieldset>
    </div>
    <div class="divider col-span-2"></div>
    <div class="col-span-2">
      <button class="btn btn-primary w-full" onclick={updateKey}
        >{#if create}Opprett{:else}Lagre{/if}</button
      >
    </div>
  </div>
{:else}
  <div class="mx-30 grid grid-cols-1 gap-4">
    <h1 class="text-center text-xl">Kunne ikke finne tilpasning!</h1>
    <a href="/admin/menu/customization/key/new" rel="external" class="btn"
      >Opprett en ny tilpasningskategori</a
    >
  </div>
{/if}
