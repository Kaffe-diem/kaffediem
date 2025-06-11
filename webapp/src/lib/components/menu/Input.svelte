<script lang="ts">
  let { value = $bindable(), label, ...props } = $props();
</script>

<fieldset class="fieldset">
  <legend class="fieldset-legend text-xl">{label}</legend>
  <input class="input input-xl w-full" bind:value {...props} />
</fieldset>
