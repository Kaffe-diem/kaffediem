<script lang="ts">
  import { pb } from "$lib/stores/authStore";
  import { onMount } from "svelte";
  import Drink from "$lib/Drink.svelte";
  let groupedDrinks: Record<string, any[]>;
  onMount(async () => {
    const drinks = await pb.collection("drinks").getFullList(100, {
      sort: "-created"
    })
    groupedDrinks = Object.groupBy(drinks, ({kind}) => kind)
  });

</script>

{#if pb.authStore.isValid}
<h1 class="my-16 text-4xl font-bold text-teal-700 italic">
  {pb.authStore.model?.name.split(" ")[0].toUpperCase()} VIL HA
</h1>{:else}
<h1 class="my-16 text-4xl font-bold text-teal-700 italic">
  JEG VIL HA
</h1>{/if}

<section>
  <h1 class="text-2xl font-bold text-red-700 italic">
    Varme drikker
  </h1>

  <ul class="grid grid-cols-3 gap-16">
    {#each groupedDrinks?.hot as drink}
      <Drink {drink} />
    {/each}
  </ul>
</section>

<section>
  <h1 class="text-2xl font-bold text-sky-700 italic">
    Kalde drikker
  </h1>

  <ul class="grid grid-cols-3 gap-16">
    {#each groupedDrinks?.cold as drink}
      <Drink {drink} />
    {/each}
  </ul>
</section>

<section>
  <h1 class="text-2xl font-bold text-orange-700 italic">
    Sesongens spesialer
  </h1>

  <ul class="grid grid-cols-3 gap-16">
    {#each groupedDrinks?.specials as drink}
      <Drink {drink} />
    {/each}
  </ul>
</section>
