<script lang="ts">
  import OrderList from "./OrderList.svelte";
  import { crossfade } from "svelte/transition";
  import { cubicOut } from "svelte/easing";
  import { OrderStateOptions } from "$lib/pocketbase";
  const { received, production, completed } = OrderStateOptions;

  const [send, receive] = crossfade({
    duration: 250,
    easing: cubicOut
  });
</script>

<div
  class="grid-rows-[repeat(5, auto)] grid h-full grid-cols-1 md:grid-cols-[2fr_auto_1fr_auto_2fr] md:grid-rows-1"
>
  <OrderList
    show={[received]}
    label="Kø"
    class="bg-base-200"
    transitionSend={send}
    transitionReceive={receive}
  />

  <div class="divider md:divider-horizontal"></div>

  <OrderList
    show={[production]}
    label="Lages nå"
    class="bg-warning"
    transitionSend={send}
    transitionReceive={receive}
  />

  <div class="divider md:divider-horizontal"></div>

  <OrderList
    show={[completed]}
    label="Ferdig"
    class="bg-primary text-base-100"
    transitionSend={send}
    transitionReceive={receive}
  />
</div>
