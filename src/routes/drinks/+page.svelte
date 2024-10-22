<script lang="ts">
  export let data: { drinks };
  const drinks = data.drinks;
</script>

<ul class="list-none">
  {#each drinks as drink}
    <li>{drink.name}</li>
  {/each}
</ul>
