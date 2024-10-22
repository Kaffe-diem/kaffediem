<script lang="ts">
  import { pb } from "$lib/stores/authStore";
  import { onMount } from "svelte";
  import Drink from "$lib/Drink.svelte";
  let groupedDrinks: Record<string, any[]>;

  onMount(async () => {
    const drinks = await pb.collection("drinks").getFullList(100, {
      sort: "-created"
    });

    groupedDrinks = Object.groupBy(drinks, ({ kind }) => kind);
  });
</script>

{#if pb.authStore.isValid}
  <h1 class="my-16 text-4xl font-bold italic text-teal-700">
    {pb.authStore.model?.name.split(" ")[0].toUpperCase()} VIL HA
  </h1>
{:else}
  <h1 class="my-16 text-4xl font-bold italic text-teal-700">JEG VIL HA</h1>
{/if}

<div class="flex flex-col gap-16">
  <section>
    <h1 class="text-2xl font-bold italic text-red-700">Varm drikke</h1>
    <ul class="grid grid-cols-3 gap-16">
      {#each groupedDrinks?.hot || [] as drink}
        <li class="drink-card">
          <Drink {drink} />
        </li>
      {/each}
    </ul>
  </section>

  <section>
    <h1 class="text-2xl font-bold italic text-sky-700">Kald drikke</h1>
    <ul class="grid grid-cols-3 gap-16">
      {#each groupedDrinks?.cold || [] as drink}
        <li class="drink-card">
          <Drink {drink} />
        </li>
      {/each}
    </ul>
  </section>

  <section>
    <h1 class="text-2xl font-bold italic text-orange-700">Sesongens spesial 🎃</h1>
    <ul class="grid grid-cols-3 gap-16">
      {#each groupedDrinks?.special || [] as drink}
        <li class="drink-card">
          <Drink {drink} />
        </li>
      {/each}
    </ul>
  </section>
</div>
