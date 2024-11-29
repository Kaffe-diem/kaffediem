<script lang="ts">
  import OrderList from "../OrderList.svelte";
  import ItemSelection from "./ItemSelection.svelte";
  import Cart from "./Cart.svelte";

  let cart: [] = $state([]);
</script>

<div class="grid h-full grid-cols-[2fr,auto,1fr,auto,1fr] grid-rows-[100%] gap-2">
  <ItemSelection {cart} />

  <div class="divider divider-horizontal m-1 p-1"></div>

  <Cart {cart} />

  <div class="divider divider-horizontal m-1 p-1"></div>

  <OrderList show={["completed"]} onclick={"dispatched"} label="Ferdig" />
</div>
