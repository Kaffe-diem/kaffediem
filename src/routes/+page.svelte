<script>
  import { auth, pb } from "$lib/stores/authStore";
  import { onMount } from "svelte";

  let isAuthenticated = false;
  let user = null;

  onMount(() => {
    const unsubscribe = auth.subscribe((value) => {
      isAuthenticated = value.isAuthenticated;
      user = value.user;
    });

    return unsubscribe;
  });
</script>

{#if isAuthenticated}
  <p>Hei {user?.name}, du er logget inn!</p>
{:else}
  <p>Hei, du er ikke logget inn :(</p>
{/if}
