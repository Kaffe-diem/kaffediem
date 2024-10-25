<script lang="ts">
  export let state: boolean = false;
</script>

<li class="step {state ? 'step-primary' : ''} p-2"><slot /></li>

<style>
  .step:after {
    @apply h-14 w-14;
  }
</style>
