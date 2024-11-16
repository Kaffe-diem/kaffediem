<script lang="ts">
  import OrderList from "../OrderList.svelte";
  import { orders } from "$lib/stores/orderStore";
</script>

<div class="grid h-full grid-cols-[3fr,auto,1.5fr,auto,1fr] grid-rows-[100%] gap-4">
  <div>
    <h2 class="mb-3 text-center text-4xl font-bold text-neutral md:mb-6">Motatt</h2>
    <OrderList {orders} show={["received"]} onclick={"production"} />
  </div>

  <div class="divider divider-horizontal"></div>

  <div>
    <h2 class="mb-3 text-center text-4xl font-bold text-neutral md:mb-6">Lages</h2>
    <OrderList {orders} show={["production"]} onclick={"completed"} />
  </div>
</div>
