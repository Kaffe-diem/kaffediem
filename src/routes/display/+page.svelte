<script lang="ts">
  import OrderList from "./OrderList.svelte";
  import { OrderStateOptions } from "$lib/pocketbase";
  const { received, production, completed } = OrderStateOptions;
</script>

<div class="grid h-full grid-cols-1 grid-rows-[1fr_auto_1fr] md:grid-cols-[1fr_1fr] md:grid-rows-1">
  <OrderList show={[received, production]} label="" class="bg-base-200" />

  <div class="bg-success">
    <OrderList show={[completed]} label="" class="bg-primary text-base-100" />
  </div>
</div>
