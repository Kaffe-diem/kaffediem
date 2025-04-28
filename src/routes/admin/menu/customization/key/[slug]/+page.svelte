<script lang="ts">
  // @ts-expect-error Is present, but lint fails
  import type { PageProps } from "./$types";
  import { customizationKeys } from "$stores/menuStore";
  import { CustomizationKey } from "$lib/types";
  import { goto } from "$app/navigation";

  import StateToggle from "$components/menu/StateToggle.svelte";
  import Input from "$components/menu/Input.svelte";

  let { data }: PageProps = $props();
  const id = data.id;
  const create = id == "new";

  let customizationName: string | undefined = $state();
  let customizationEnabled: boolean = $state(true);
  let customizationColor: string | undefined = $state("#CCCCCC");

  let exists: boolean = $state(false);

  $effect(() => {
    const key = $customizationKeys.find((key) => key.id === id);
    if (key) {
      customizationName = key.name;
      customizationEnabled = key.enabled;
      customizationColor = key.labelColor;

      exists = true;
    }
  });

  function updateKey() {
    if (create) {
      customizationKeys.create(
        new CustomizationKey(id, customizationName!, customizationEnabled, customizationColor!)
      );
    } else {
      customizationKeys.update(
        new CustomizationKey(id, customizationName!, customizationEnabled, customizationColor!)
      );
    }
    goto("/admin/menu/customization");
  }
</script>

{#if create}
  <h1 class="text-center text-xl">Opprett en tilpasningskategori</h1>
  <div class="divider"></div>
{/if}
{#if exists}
  <form onsubmit={updateKey} class="grid w-full grid-cols-2 gap-2">
    <h1 class="col-span-2 text-left text-2xl">Rediger tilpasningskategori</h1>
    <div class="divider col-span-2"></div>
    <div class="col-span-2">
      <Input label="Navn" type="text" required placeholder="Navn" bind:value={customizationName} />
    </div>
    <div>
      <StateToggle bind:state={customizationEnabled} />
    </div>
    <div>
      <Input label="Farge" type="color" bind:value={customizationColor} />
    </div>
    <div class="divider col-span-2"></div>
    <div class="col-span-2">
      <button type="submit" class="btn btn-primary w-full"
        >{#if create}Opprett{:else}Lagre{/if}</button
      >
    </div>
  </form>
{:else}
  <div class="mx-30 grid grid-cols-1 gap-4">
    <h1 class="text-center text-xl">Kunne ikke finne tilpasningskategori!</h1>
    <a href="/admin/menu/customization/key/new" rel="external" class="btn"
      >Opprett en ny tilpasningskategori</a
    >
  </div>
{/if}
