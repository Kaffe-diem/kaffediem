<script lang="ts">
  import {
    categories,
    items,
    customizationKeys,
    customizationValues,
    itemCustomizations
  } from "$stores/menuStore";

  import { raw_orders, userOrders } from "$stores/orderStore";
  import orders from "$stores/orderStore";
  // import { status } from "$stores/statusStore"; // TODO

  function reset() {
    categories.reset();
    items.reset();
    customizationKeys.reset();
    customizationValues.reset();
    itemCustomizations.reset();
    raw_orders.reset();
    userOrders.reset();
    orders.reset();
  }
</script>

<button onclick={reset} class="btn btn-lg btn-secondary">r</button>
