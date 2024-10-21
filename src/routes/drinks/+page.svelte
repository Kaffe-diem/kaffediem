<script lang="ts">
  import { pb } from "$lib/stores/authStore";
  import { onMount } from "svelte";

  let drinks: any[] = [];

  onMount(async () => {
    drinks = await pb.collection("drinks").getFullList(100, {
      sort: "-created"
    });
  });
</script>

<ul class="list-none">
  {#each drinks as drink}
    <li>{drink.name}</li>
  {/each}
</ul>
