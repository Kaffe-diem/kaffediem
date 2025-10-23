<script lang="ts">
  import Step from "$components/Step.svelte";

  let queuePosition = 10;
</script>

<div class="text-center">
  <h2 class="text-2xl">999</h2>
  {#if true}
    <h2 class="mt-6 text-xl">
      Du er nr. {queuePosition} i køen!
    </h2>
  {/if}

  <ul class="steps steps-vertical md:steps-horizontal mt-12 text-xl">
    <Step state={true}>Motatt</Step>
    <Step state={false}>Straks ferdig...</Step>
    <Step state={false}>Kom og hent!</Step>
  </ul>
</div>
