<script lang="ts">
  import OrderList from "./OrderList.svelte";
  import { OrderStateOptions } from "$lib/pocketbase";
  const { received, production, completed } = OrderStateOptions;
</script>

<div
  class="grid h-full grid-cols-1 grid-rows-[1fr_auto_1fr] gap-4 md:grid-cols-[1fr_auto_1fr] md:grid-rows-1"
>
  <OrderList show={[received, production]} label="Straks ferdig..." class="text-neutral" />

  <div class="divider md:divider-horizontal"></div>

  <OrderList show={[completed]} label="Kom og hent!" class="text-primary" />
</div>
