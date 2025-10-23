<script lang="ts">
  import { OrderStateOptions } from "$lib/types";
  import OrderList from "../orders/OrderList.svelte";

  const { received, production, completed, dispatched } = OrderStateOptions;
</script>

<div class="grid h-screen grid-rows-[1fr_auto] p-4">
  <OrderList show={[received, production, completed, dispatched]} label="Dagens bestillinger" />
</div>
