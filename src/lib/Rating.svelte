<script lang="ts">
  export let value: number;
  export let readonly: boolean = false;
  // Name is only required when the component's value can change
  export let name: string;

  function inputChange(newValue: number) {
    value = newValue;
  }
</script>

<div class="rating rating-half block {$$restProps.class || ''}">
  {#each Array(10) as _, n}
    <input
      type="radio"
      {name}
      class="mask-coffee mask {n % 2 == 0 ? 'mask-half-1' : 'mask-half-2'} bg-accent {readonly
        ? 'cursor-default'
        : ''}"
      checked={n == value - 1}
      disabled={readonly}
      on:change={() => inputChange(n + 1)}
    />
  {/each}
</div>

<style>
  .mask-coffee {
    mask-image: url("$lib/assets/coffee.svg");
  }
</style>
