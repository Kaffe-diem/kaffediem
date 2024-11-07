<script lang="ts">
  import OrderList from "./OrderList.svelte";
  import ItemSelection from "./ItemSelection.svelte";
  import Cart from "./Cart.svelte";
  import { orders } from "$lib/stores/orderStore";

  let { data } = $props();
  let selectedItem = $state();
</script>

<div class="grid h-full grid-cols-[3fr,auto,1.5fr,auto,1fr] grid-rows-[100%] gap-4">
  <ItemSelection categories={data.categories} bind:selectedItem />

  <div class="divider divider-horizontal"></div>

  <Cart {selectedItem} />

  <div class="divider divider-horizontal"></div>

  <OrderList orders={$orders} show={"complete"} />
</div>
