<script lang="ts">
  import OrderList from "../OrderList.svelte";
  import { orders } from "$lib/stores/orderStore";
</script>

<div class="grid h-full grid-cols-[1fr,auto,1fr] grid-rows-[100%] gap-4">
  <OrderList {orders} show={["received"]} onclick={"production"} label="Mottatt" />

  <div class="divider divider-horizontal"></div>

  <OrderList {orders} show={["production"]} onclick={"completed"} label="Lages" />
</div>
