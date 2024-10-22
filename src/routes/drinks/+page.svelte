<script lang="ts">
  import { onMount } from 'svelte';
  import { pb } from "$lib/stores/authStore";

  let drinks: any[] = [];

  async function getDrinks(): { drinks: any[]}
  {
    return await pb.collection('drinks').getFullList( { sort: '-created' }) ;
  }

  onMount(async () => {

    const data = await getDrinks();
    drinks = data;

    pb.collection('drinks').subscribe('*', (data) => {
      drinks = data;
    });
  });
</script>

<ul class="list-none">
  {#each drinks as drink}
    <li>{drink.name}</li>
  {/each}
</ul>
