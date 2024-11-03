<script lang="ts">
  import { State, Order } from "$lib/types";
  import OrderList from "./OrderList.svelte";
  // TODO: instead of having an Order-type, interface directly with the DB using a svelte store
  $: orders = [
    new Order(123),
    new Order(456, State.Complete),
    new Order(789, State.Complete),
    new Order(999, State.Complete),
    new Order(999, State.Complete),
    new Order(999, State.Complete),
    new Order(999, State.Complete),
    new Order(999, State.Complete),
    new Order(999, State.Complete),
    new Order(999, State.Complete),
    new Order(999, State.Complete),
    new Order(999, State.Complete),
    new Order(999, State.Complete)
  ];

  export let data;
  // Is undefined before anything is checked.
  // Make sure to account for that when implementing logic based on it.
  let selectedDrink;

  let cart = [];
  $: totalPrice = cart.reduce((sum, item) => sum + item.price, 0);
  function addToCart() {
    // Has to be re-assigned to trigger reactivity..
    // https://svelte.dev/tutorial/svelte/deep-state
    // ↑ does not seem to work here /shrug
    cart = [...cart, selectedDrink];
    // selectedDrink = undefined;
  }

  function removeFromCart(index) {
    // Same as above :(
    // cart.splice(index, 1);
    // cart = [...cart];
    cart = cart.slice(0, index).concat(cart.slice(index + 1));
  }
</script>

<div class="grid h-full grid-cols-[3fr,auto,1.5fr,auto,1fr] grid-rows-[100%] gap-4">
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

  <div class="flex h-full flex-col justify-center gap-8">
    <div class="h-1/2 overflow-y-auto">
      <table class="table table-pin-rows table-auto list-none p-4 shadow-2xl">
        <thead>
          <tr>
            <th class="w-full">Drikke</th>
            <th class="whitespace-nowrap">Pris</th>
          </tr>
        </thead>
        <tbody>
          {#if cart.length > 0}
            {#each cart as drink, index}
              <tr class="hover select-none" on:click={() => removeFromCart(index)}>
                <td>{drink.name}</td>
                <td>{drink.price},-</td>
              </tr>
            {/each}
          {:else}
            <tr>
              <td>Ingenting</td>
              <td></td>
            </tr>
          {/if}
        </tbody>
        <tfoot>
          <tr>
            <th>Total</th>
            <th><span class="text-bold text-lg text-primary">{totalPrice},-</span></th>
          </tr>
        </tfoot>
      </table>
    </div>

    <div class="flex flex-row justify-center gap-2">
      <button class="bold btn btn-lg text-xl">Ferdig</button>
      <button class="bold btn btn-primary btn-lg text-3xl" on:click={addToCart}>+</button>
    </div>
  </div>

  <div class="divider divider-horizontal"></div>

  <div class="overflow-y-auto">
    <OrderList {orders} filter={State.Complete} />
  </div>
</div>
