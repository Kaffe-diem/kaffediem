<script lang="ts">
  import { OrderStateOptions } from "$lib/pocketbase";
  import OrderList from "../OrderList.svelte";
  import orders from "$stores/orderStore";

  const { received, production, completed } = OrderStateOptions;
</script>

<div class="grid h-screen grid-rows-[1fr_auto] p-4">
  <div class="grid max-h-screen grid-cols-[1fr_auto_1fr] gap-4 overflow-y-auto">
    <OrderList show={[received]} onclick={production} label="Mottatt" />

    <div class="divider divider-horizontal"></div>

    <OrderList show={[production]} onclick={completed} label="Lages" />
  </div>

  <button class="btn btn-lg btn-error mt-4" onclick={() => orders.undoLastAction()}>oops</button>
</div>
