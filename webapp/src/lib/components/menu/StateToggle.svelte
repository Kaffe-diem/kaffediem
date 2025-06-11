<script lang="ts">
  let { state = $bindable(true) }: { state: boolean } = $props();

  function toggleState() {
    state = !state;
  }
</script>

<fieldset class="fieldset">
  <legend class="fieldset-legend text-xl">Aktivert</legend>
  <button class="btn btn-xl {state ? '' : 'btn-neutral'}" onclick={toggleState}
    >{#if state}Synlig{:else}Deaktivert{/if}</button
  >
</fieldset>
