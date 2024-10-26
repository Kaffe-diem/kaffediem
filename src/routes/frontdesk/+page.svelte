<script lang="ts">
  import { pb } from "$lib/stores/authStore";
  let groupedDrinks: Record<string, any[]>;

  export let data = { drinks: [] };
  groupedDrinks = Object.groupBy(data.drinks, ({ kind }) => kind);
</script>

<div class="flex flex-col gap-16">
  <section>
    <h1 class="text-2xl font-bold italic text-red-700">Varm drikke</h1>
    <ul class="grid grid-cols-1 gap-16 md:grid-cols-8">
      {#each groupedDrinks?.hot || [] as drink}
        <input type="radio" aria-label={drink.name} class="btn" />
      {/each}
    </ul>
  </section>

  <section>
    <h1 class="text-2xl font-bold italic text-sky-700">Kald drikke</h1>
    <ul class="grid grid-cols-1 gap-16 md:grid-cols-8">
      {#each groupedDrinks?.cold || [] as drink}
        <input type="radio" aria-label={drink.name} class="btn" />
      {/each}
    </ul>
  </section>

  <section>
    <h1 class="text-2xl font-bold italic text-orange-700">Sesongens spesial 🎃</h1>
    <ul class="grid grid-cols-1 gap-16 md:grid-cols-8">
      {#each groupedDrinks?.special || [] as drink}
        <input type="radio" aria-label={drink.name} class="btn" />
      {/each}
    </ul>
  </section>
</div>
