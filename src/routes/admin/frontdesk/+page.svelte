<script lang="ts">
  import OrderList from "../OrderList.svelte";
  import ItemSelection from "./ItemSelection.svelte";
  import Cart from "./Cart.svelte";
  import { activeMessage } from "$stores/messageStore";
  import { ActiveMessage } from "$lib/types";

  let selectedItem = $state();
</script>

{#if $activeMessage.visible}
  <div class="flex h-full w-full flex-col items-center justify-center">
    <span class="p-2 text-center text-3xl font-bold md:text-6xl">Det er stengt</span>
    <button
      class="btn relative m-4 flex h-24 w-1/2 flex-col items-center justify-center text-3xl lg:text-5xl
"
      onclick={() =>
        activeMessage.update(
          new ActiveMessage({
            ...$activeMessage,
            visible: false
          })
        )}>Åpne</button
    >
    <a
      href="/admin/message"
      class="btn relative m-4 flex h-24 w-1/2 flex-col items-center justify-center text-3xl lg:text-5xl"
      >Eller endre status</a
    >
  </div>
{:else}
  <div class="grid h-full grid-cols-[2fr,auto,1fr,auto,1fr] grid-rows-[100%] gap-2">
    <ItemSelection bind:selectedItem />

    <div class="divider divider-horizontal m-1 p-1"></div>

    <Cart {selectedItem} />

    <div class="divider divider-horizontal m-1 p-1"></div>

    <OrderList show={["completed"]} onclick={"dispatched"} label="Ferdig" />
  </div>
{/if}
