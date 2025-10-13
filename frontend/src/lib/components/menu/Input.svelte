<script lang="ts">
  let {
    value = $bindable(),
    label,
    type = "text",
    required = false,
    placeholder,
    min
  } = $props<{
    value: string | number | undefined;
    label: string;
    type: string;
    required?: boolean;
    placeholder?: string;
    min?: number;
  }>();
</script>

<fieldset class="fieldset">
  <legend class="fieldset-legend text-xl">{label}</legend>
  <input class="input input-xl w-full" bind:value {type} {required} {placeholder} {min} />
</fieldset>
