<script lang="ts">
  import PocketBase from "pocketbase";
  import { onMount } from "svelte";
  // prefixed with PUBLIC_ means that the variables can be read by the frontend. This is very unsafe, and is only temporary for testing !!
  import {PUBLIC_PB_URL, PUBLIC_PB_ADMIN_EMAIL, PUBLIC_PB_ADMIN_PASSWORD} from "$env/static/public";

  async function getDrinks() {
    // Init
    const pb = new PocketBase(PUBLIC_PB_URL);
    await pb.admins.authWithPassword(PUBLIC_PB_ADMIN_EMAIL, PUBLIC_PB_ADMIN_PASSWORD);

    const result = await pb.collection("drinks").getFullList({
      sort: "-created"
    });

    console.log(result);

    return result
  }

  let drinks = []
  onMount(async () => {
    drinks = await getDrinks();
  })
</script>

<ul class="list-none">
  {#each drinks as drink}
    <li>{drink.name}</li>
  {/each}
</ul>
