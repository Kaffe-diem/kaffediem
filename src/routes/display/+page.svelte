<script lang="ts">
  import OrderList from "$lib/OrderList.svelte";
  import { State, Order } from "$lib/types";
  import QR from "$lib/assets/qr-code.svg";

  $: orders = [new Order(123), new Order(456), new Order(789, State.Complete)];
</script>

  <div class="h-full grid grid-cols-1 gap-4 md:grid-cols-2">
    <div class="flex h-full flex-col border-b-2 border-neutral p-4 md:border-b-0 md:border-r-2">
      <h2 class="mb-3 text-4xl text-neutral font-bold md:mb-6 md:text-center md:text-4xl">Straks ferdig...</h2>
      <OrderList {orders} filter={State.Production} />
    </div>
    <div class="flex h-full flex-col p-4">
      <h2 class="mb-3 text-4xl font-bold text-primary md:mb-6 md:text-center md:text-4xl">
        Kom og hent!
      </h2>
      <OrderList {orders} filter={State.Complete} />
    </div>
  </div>

  <div class="absolute bottom-4 left-0 hidden md:flex">
    <a href="/">
      <img class="h-24 w-24" src={QR} alt="QR code"/>
    </a>
    <div class="flex flex-col items-start justify-center ml-2 py-1 text-sm text-neutral">
      <span>Skann eller besøk</span>
      <a href="https://kaffediem.asvg.no" class="font-bold text-accent">kaffediem.asvg.no</a>
      <span>for å bestille</span>
    </div>
  </div>
