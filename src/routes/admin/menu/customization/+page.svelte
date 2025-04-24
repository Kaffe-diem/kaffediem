<script lang="ts">
  import { customizationKeys, customizationValues } from "$stores/menuStore";

  // TODO: Extract this logic into the store itself, such that it does not have to be done manually every time.
  const customizationGroups = $derived(
    $customizationValues.reduce((acc, item) => {
      if (!acc[item.belongsTo]) {
        acc[item.belongsTo] = [];
      }
      acc[item.belongsTo].push(item);
      return acc;
    }, {})
  );
</script>

<h1 class="mb-8 text-2xl">Tilpasninger</h1>

<div class="flex flex-col gap-8 overflow-y-auto">
  <div class="flex flex-col gap-2">
    <a href="/admin/menu/customization/key/new" class="btn w-full"
      >Opprett en ny tilpasningskategori</a
    >
    <a href="/admin/menu/customization/value/new" class="btn w-full">Opprett en ny tilpasning</a>
  </div>
  {#each $customizationKeys as key}
    <div>
      <div class="mb-4 flex flex-row items-center justify-between px-2">
        <span class="text-2xl">{key.name}</span>
        <div class="flex flex-row items-center gap-4">
          <a href="/admin/menu/customization/key/{key.id}" class="btn btn-neutral">Rediger</a>
        </div>
      </div>
      <ul class="list-none">
        {#each customizationGroups[key.id] as customization}
          <li class="m-2 flex flex-row justify-between">
            <span>{customization.name}</span>
            <a
              href="/admin/menu/customization/value/{customization.id}"
              class="btn"
              style={key.labelColor ? `background-color: ${key.labelColor};` : null}>Rediger</a
            >
          </li>
        {/each}
      </ul>
    </div>
  {/each}
</div>
