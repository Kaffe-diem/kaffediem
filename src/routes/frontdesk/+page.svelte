<script lang="ts">
  import { State, Order } from "$lib/types";
  import OrderList from "$components/OrderList.svelte";
  // TODO: instead of having an Order-type, interface directly with the DB using a svelte store
  $: orders = [new Order(123), new Order(456), new Order(789, State.Complete)];

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

<div class="grid h-full grid-cols-[3fr,auto,1fr,auto,1fr] grid-rows-[100%] gap-4">
  <div class="flex flex-col overflow-y-auto">
    {#each data.categories as category}
      <div class="mb-8">
        <h1 class="mb-4 text-2xl font-bold text-primary">{category.name}</h1>
        <div class="grid grid-cols-1 gap-6 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4">
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
        </div>
      </div>
    {/each}
  </div>

  <div class="divider divider-horizontal"></div>

  <div class="flex h-full flex-col justify-evenly gap-8 py-36">
    <ul class="h-lg list-none p-4 shadow-2xl">
      <li>Mocca</li>
      <li>Latte</li>
      <li>Cappuccino</li>
      <li>Cappuccino</li>
      <li>Cappuccino</li>
      <li>Catppuccin</li>
      <li>Cappuccino</li>
    </ul>

    <div class="flex flex-row justify-center gap-2">
      <button class="bold btn btn-lg text-xl">Ferdig</button>
      <button class="bold btn btn-accent btn-lg text-3xl">+</button>
    </div>
  </div>

  <div class="divider divider-horizontal"></div>

  <OrderList {orders} filter={State.Complete} />
</div>
