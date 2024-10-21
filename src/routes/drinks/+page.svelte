<script lang="ts">
  import { onMount } from 'svelte';

  export let data: { drinks: any[] };

  let drinks = data.drinks;
  
  onMount(() => {
    // Client-side subscription to real-time updates (if needed)
    const pb = new PocketBase('https://your-pocketbase-url.com');
    
    pb.collection('drinks').subscribe('*', (data) => {
      console.log(data);  // Handle real-time updates here
    });
  });
</script>

<ul class="list-none">
  {#each drinks as drink}
    <li>{drink.name}</li>
  {/each}
</ul>
