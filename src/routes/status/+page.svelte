<script lang="ts">
  import type { State } from "$lib/types";
  import { Order } from "$lib/types";
  import Step from "$components/Step.svelte";
  import { stateColors } from "$lib/constants";

  // let order = new Order(999, State.Received);
  // let order = new Order(999, State.Production);
  // let order = new Order(999, State.Complete);
  let queuePosition = 10;

  // let orderReceived = $derived(order.state == State.Received);
  // let orderProduction = $derived(order.state > State.Received);
  // let orderComplete = $derived(order.state > State.Production);

  let orderColor = $derived(stateColors[order.state]);
  console.log(order.state);
  console.log(stateColors[order.state]);
  console.log(orderColor);
</script>

<div class="text-center font-bold text-neutral">
  <!-- Tailwind requires: text-neutral text-yellow-600 text-primary -->
  <h2 class="mb-3 text-6xl md:mb-6 md:text-7xl text-{orderColor}">{order.id}</h2>

  <ul class="steps steps-vertical mt-12 text-xl md:steps-horizontal">
    <Step state={true} color={orderColor}>Motatt</Step>
    <Step state={orderProduction} color={orderColor}>Straks ferdig...</Step>
    <Step state={orderComplete} color={orderColor}>Kom og hent!</Step>
  </ul>

  {#if orderReceived}
    <h2 class="mt-12 text-2xl md:text-3xl">
      Du er nr. {queuePosition} i køen!
    </h2>
  {/if}
</div>
