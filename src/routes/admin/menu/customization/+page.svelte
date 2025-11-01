<script lang="ts">
  import { resolve } from "$app/paths";
  import { menuIndexes } from "$stores/menu";
</script>

<h1 class="mb-8 text-3xl">Tilpasninger</h1>

<div class="flex flex-col gap-8 overflow-y-auto">
  <div class="flex flex-col gap-2">
    <a href={resolve("/admin/menu")} class="btn btn-neutral btn-lg w-full">Rediger meny</a>
    <a href={resolve("/admin/menu/customization/key/new")} class="btn btn-lg w-full"
      >Opprett en ny tilpasningskategori</a
    >
    <a href={resolve("/admin/menu/customization/value/new")} class="btn btn-lg w-full"
      >Opprett en ny tilpasning</a
    >
  </div>
  {#each $menuIndexes.customization_keys as key (key.id)}
    <div>
      <div class="mb-4 flex flex-row items-center justify-between px-2">
        <span class="text-3xl">{key.name}</span>
        <div class="flex flex-row items-center gap-4">
          {#if !key.enable}
            <span class="badge badge-xl badge-soft badge-neutral italic">Deaktivert</span>
          {/if}
          <a
            href={resolve(`/admin/menu/customization/key/${key.id}`)}
            class="btn btn-lg btn-neutral">Rediger</a
          >
        </div>
      </div>
      <ul class="list-none">
        {#each $menuIndexes.customizations_by_key[key.id] ?? [] as customization (customization.id)}
          <li class="m-2 flex flex-row justify-between">
            <span class="text-xl">{customization.name}</span>
            <div class="flex flex-row items-center gap-4">
              {#if !customization.enable}
                <span class="badge badge-xl badge-soft badge-neutral">Deaktivert</span>
              {/if}
              <a
                href={resolve(`/admin/menu/customization/value/${customization.id}`)}
                class="btn btn-lg"
                style={key.label_color ? `background-color: ${key.label_color};` : null}>Rediger</a
              >
            </div>
          </li>
        {/each}
      </ul>
    </div>
  {/each}
</div>
