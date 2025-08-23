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

<div class="grid h-full grid-cols-[3fr_auto_2fr_auto_1fr] grid-rows-[100%] gap-0 p-4">
  <ItemSelection bind:selectedItem />

  <div class="divider divider-horizontal m-0 p-0"></div>

  <div class="flex flex-col">
    <CustomizationSelection />
    <Cart {selectedItem} />
  </div>

  <div class="divider divider-horizontal m-0 p-0"></div>

  <div class="flex h-full flex-col">
    <OrderList
      show={[OrderStateOptions.completed]}
      onclick={OrderStateOptions.dispatched}
      label="Ferdig"
      detailed={false}
    />
    <button class="btn btn-lg mb-16 2xl:mb-0" onclick={() => orders.undoLastAction()}>oops</button>
  </div>
</div>
