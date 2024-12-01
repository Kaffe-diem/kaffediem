<script lang="ts">
  interface Props {
    state: boolean;
    children?: import("svelte").Snippet;
  }

  let { state, children }: Props = $props();
</script>

<li class="step {state ? 'step-primary' : ''} p-2">{@render children?.()}</li>

<style>
  .step:after {
    @apply h-14 w-14;
  }
</style>
