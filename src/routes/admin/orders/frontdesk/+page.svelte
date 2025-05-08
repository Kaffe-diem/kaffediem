<script lang="ts">
  import OrderList from "../OrderList.svelte";
  import ItemSelection from "./ItemSelection.svelte";
  import Cart from "./Cart.svelte";
  import CustomizationSelection from "./CustomizationSelection.svelte";
  import { OrderStateOptions as OrderStateOptions } from "$lib/pocketbase";
  import type { Item } from "$lib/types";
  import orders from "$stores/orderStore";

  let selectedItem = $state<Item | undefined>();
</script>

<div class="grid h-full grid-cols-[2fr_auto_1fr_auto_1fr] grid-rows-[100%] gap-2">
  <ItemSelection bind:selectedItem />

  <div class="divider divider-horizontal m-1 p-1"></div>

  <div class="flex h-full flex-col gap-4">
    <CustomizationSelection />
    <Cart {selectedItem} />
  </div>

  <div class="divider divider-horizontal m-1 p-1"></div>

  <div class="flex h-full flex-col">
    <OrderList
      show={[OrderStateOptions.completed]}
      onclick={OrderStateOptions.dispatched}
      label="Ferdig"
    />
    <button class="btn btn-lg" onclick={() => orders.undoLastAction()}>oops</button>
  </div>
</div>
