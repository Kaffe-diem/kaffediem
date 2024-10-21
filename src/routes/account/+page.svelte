<script lang="ts">
    import { PUBLIC_PB_HOST } from "$env/static/public";
import { pb } from "$lib/stores/authStore";
import { onMount } from "svelte";
import Drink from "$lib/Drink.svelte";

let favorites: any[] = [];

onMount(async () => {
  const favoriteIds = pb.authStore.model?.favorites;
  // all
  favorites = await pb.collection("order_drink").getFullList(100, {
    expand: "drink",
  });
  // or single attached to user
  favorites = await pb.collection("order_drink").getOne(favoriteIds[0]);
});

</script>

<h1 class="my-16 text-4xl font-bold text-teal-700 italic">
  {pb.authStore.model?.name.split(" ")[0].toUpperCase()} ELSKER
</h1>
<div class="grid grid-cols-3 gap-16">
  {#each favorites as favorite}
    <Drink {favorite} />
  {/each}
</div>
