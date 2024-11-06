<script lang="ts">
  

  function inputChange(newValue: number) {
    value = newValue;
  }

  interface Props {
    value?: number;
    readonly?: boolean;
    // Name is only required when the component's value can change
    name?: string;
    maxRating?: number;
    [key: string]: any
  }

  let {
    value = $bindable(0),
    readonly = false,
    name = null,
    maxRating = 10,
    ...rest
  }: Props = $props();
  const items = Array.from({ length: maxRating }, (_, i) => i + 1); // Ascending list from 1 to maxRating
</script>

<div class="rating rating-half block {rest.class || ''}">
  <!-- Required for tailwind to compile classes: -->
  <!-- The following classes are used: mask-half-1 mask-half-2 -->
  {#each items as n}
    <input
      type="radio"
      {name}
      class="mask-coffee mask {'mask-half-' + (2 - (n % 2))} bg-accent {readonly
        ? 'cursor-default'
        : ''}"
      checked={n == value}
      disabled={readonly}
      onchange={() => inputChange(n)}
    />
  {/each}
</div>

<style>
  .mask-coffee {
    mask-image: url("$assets/coffee.svg");
  }
</style>
