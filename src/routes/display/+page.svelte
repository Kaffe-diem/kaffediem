<script lang="ts">
  import OrderList from "./OrderList.svelte";
  import { OrderStateOptions } from "$lib/pocketbase";
  const { received, production, completed } = OrderStateOptions;
</script>

<div
  class="grid h-full grid-cols-1 grid-rows-[auto_auto_auto_auto_auto] md:grid-cols-[1fr_auto_1fr_auto_1fr] md:grid-rows-1"
>
  <OrderList show={[received]} label="Kø" class="bg-base-200" />

  <div class="divider md:divider-horizontal"></div>

  <OrderList show={[production]} label="Lages nå" class="bg-base-200" />

  <div class="divider md:divider-horizontal"></div>

  <OrderList show={[completed]} label="Ferdig" class="bg-primary text-base-100" />
</div>
