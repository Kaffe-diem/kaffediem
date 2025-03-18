<script lang="ts">
  import OrderList from "../OrderList.svelte";
  import ItemSelection from "./ItemSelection.svelte";
  import Cart from "./Cart.svelte";
  import CustomizationSelection from "./CustomizationSelection.svelte";
  import { OrderStateOptions as OrderStateOptions } from "$lib/pocketbase";
  import type { Item } from "$lib/types";

  let selectedItem = $state<Item | undefined>();
</script>

<div class="grid h-full grid-cols-[2fr,auto,1fr,auto,1fr] grid-rows-[100%] gap-2">
  <ItemSelection bind:selectedItem />

  <div class="divider divider-horizontal m-1 p-1"></div>

  <div class="flex h-full flex-col gap-4">
    <CustomizationSelection/>
    <Cart selectedItem={selectedItem} />
  </div>

  <div class="divider divider-horizontal m-1 p-1"></div>

  <OrderList
    show={[OrderStateOptions.completed]}
    onclick={OrderStateOptions.dispatched}
    label="Ferdig"
  />
</div>
