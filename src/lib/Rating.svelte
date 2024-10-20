<script lang="ts">
  export let value: number;
  export let readonly: boolean = false;
</script>

<div class="rating rating-half block {$$restProps.class || ''}">
  {#each Array(10) as _, n}
    <input type="radio" class="mask mask-star-2 {n % 2 == 0 ? 'mask-half-1' : 'mask-half-2'} bg-accent" checked={n == value - 1} disabled={readonly} />
  {/each}
</div>
