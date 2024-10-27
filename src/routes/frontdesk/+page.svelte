<script lang="ts">
  export let data;

  // Is undefined before anything is checked.
  // Make sure to account for that when implementing logic based on it.
  let selectedDrink;
</script>

{#if selectedDrink}
  <p class="mb-4">
    Valgt drikke: {selectedDrink.name}
  </p>
{/if}

<div class="flex flex-col gap-8">
  {#each data.categories as category}
    <section>
      <h1 class="mb-4 text-2xl font-bold text-primary">{category.name}</h1>
      <ul class="grid grid-cols-2 gap-6 md:grid-cols-3 lg:grid-cols-4 xl:grid-cols-5">
        {#each category.expand.drinks_via_category as drink}
          <label>
            <input
              type="radio"
              name="drink"
              class="peer hidden"
              value={drink}
              bind:group={selectedDrink}
            />
            <div
              class="btn relative flex h-24 w-full flex-col items-center justify-center border-4 peer-checked:border-accent"
            >
              <span class="font-bold">{drink.name}</span>
              <span class="absolute bottom-2 right-2 font-normal">{drink.price},-</span>
            </div>
          </label>
        {/each}
      </ul>
    </section>
  {/each}
</div>
