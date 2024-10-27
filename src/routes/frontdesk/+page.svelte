<script lang="ts">
  export let data;
</script>

<div class="flex flex-col gap-8">
  {#each data.categories as category}
    <section>
      <h1 class="text-2xl mb-4 font-bold italic text-primary">{category.label}</h1>
      <ul class="grid gap-6 grid-cols-2 md:grid-cols-3 lg:grid-cols-4 xl:grid-cols-5">
        {#each data.drinks[category.name] as drink}
          <label>
            <input type="radio" name="drink" class="hidden peer" />
            <div class="w-full h-24 btn border-2 peer-checked:border-accent relative flex justify-center items-center flex-col">
              <span class="font-bold">{drink.name}</span>
              <span class="font-normal absolute bottom-2 right-2">{drink.price},-</span>
            </div>
          </label>
        {/each}
      </ul>
    </section>
  {/each}
</div>
