<script lang="ts">
  let { state = $bindable(true) }: { state: boolean } = $props();

  function toggleState() {
    state = !state;
  }
</script>

<fieldset class="fieldset">
  <legend class="fieldset-legend">Aktivert</legend>
  <button class="btn {state ? '' : 'btn-neutral'}" onclick={toggleState}
    >{#if state}Synlig{:else}Deaktivert{/if}</button
  >
</fieldset>
