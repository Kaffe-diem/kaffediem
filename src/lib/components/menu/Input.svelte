<script lang="ts">
  let { value = $bindable(), label, ...props } = $props();
</script>

<fieldset class="fieldset">
  <legend class="fieldset-legend">{label}</legend>
  <input class="input w-full" bind:value {...props} />
</fieldset>
