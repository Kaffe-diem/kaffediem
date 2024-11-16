<script lang="ts">
  import OrderList from "../OrderList.svelte";
  import { orders } from "$lib/stores/orderStore";
</script>

<div class="grid h-full grid-cols-[3fr,auto,1.5fr,auto,1fr] grid-rows-[100%] gap-4">
  <OrderList {orders} show={["received"]} onclick={"production"} />

  <div class="divider divider-horizontal"></div>

  <OrderList {orders} show={["production"]} onclick={"completed"} />
</div>
