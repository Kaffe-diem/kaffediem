<script lang="ts">
  export let value: number = 0;
  export let readonly: boolean = false;
  // Name is only required when the component's value can change
  export let name: string = null;

  function inputChange(newValue: number) {
    value = newValue;
  }

  export let maxRating: number = 10;
  const items = Array.from({ length: maxRating }, (_, i) => i + 1); // Ascending list from 1 to maxRating
</script>

<div class="rating rating-half block {$$restProps.class || ''}">
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
      on:change={() => inputChange(n)}
    />
  {/each}
</div>

<style>
  .mask-coffee {
    mask-image: url("$assets/coffee.svg");
  }
</style>
