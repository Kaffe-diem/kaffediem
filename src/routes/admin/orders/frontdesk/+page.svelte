<script lang="ts">
  import OrderList from "../OrderList.svelte";
  import ItemSelection from "./ItemSelection.svelte";
  import Cart from "./Cart.svelte";
  import CustomizationSelection from "./CustomizationSelection.svelte";
  import { OrderStateOptions } from "$lib/types";
  import { orders, undoLastStateChange } from "$stores/orders";
</script>

<div class="grid h-full grid-cols-[5fr_auto_5fr_auto_3fr] grid-rows-[100%] gap-0 p-4">
  <ItemSelection />

  <div class="divider divider-horizontal m-0 p-0"></div>

  <div class="flex flex-col">
    <CustomizationSelection />
    <Cart />
  </div>

  <div class="divider divider-horizontal m-0 p-0"></div>

  <div class="flex h-full flex-col">
    <OrderList
      show={[OrderStateOptions.completed]}
      onclick={OrderStateOptions.dispatched}
      label="Ferdig"
      detailed={false}
    />
    <button class="btn btn-lg btn-error mb-16 2xl:mb-0" onclick={() => undoLastStateChange()}
      >oops</button
    >
  </div>
</div>
