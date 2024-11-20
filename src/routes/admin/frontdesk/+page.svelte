<script lang="ts">
  import OrderList from "../OrderList.svelte";
  import ItemSelection from "./ItemSelection.svelte";
  import Cart from "./Cart.svelte";
  import { orders } from "$lib/stores/orderStore";

  let { data } = $props();
  let selectedItem = $state();
</script>

<div class="grid h-full grid-cols-[2fr,auto,1fr,auto,1fr] grid-rows-[100%] gap-2">
  <ItemSelection categories={data.categories} bind:selectedItem />

  <div class="divider divider-horizontal m-1 p-1"></div>

  <Cart {selectedItem} />

  <div class="divider divider-horizontal m-1 p-1"></div>

  <OrderList {orders} show={["completed"]} onclick={"dispatched"} label="Ferdig" />
</div>
