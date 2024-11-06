<script lang="ts">
  import { State, Order } from "$lib/types";
  import OrderList from "./OrderList.svelte";
  import ItemSelection from "./ItemSelection.svelte";
  import Cart from "./Cart.svelte";

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
  let selectedItem;
</script>

<div class="grid h-full grid-cols-[3fr,auto,1.5fr,auto,1fr] grid-rows-[100%] gap-4">
  <ItemSelection categories={data.categories} bind:selectedItem />

  <div class="divider divider-horizontal"></div>

  <Cart {selectedItem} />

  <div class="divider divider-horizontal"></div>

  <OrderList {orders} filter={State.Complete} />
</div>
