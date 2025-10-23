<script lang="ts">
  import auth from "$stores/auth";
  import Status from "./Status.svelte";
</script>

{#if $auth.isAuthenticated}
  <h1 class="mb-4 flex items-center text-2xl">
    Hei, {$auth.user.name}{#if $auth.user.isAdmin}<span class="badge badge-primary badge-lg ml-2"
        >Admin</span
      >{/if}
  </h1>

  <Status />
{:else}
  <h1 class="text-2xl">Du er ikke logget inn!</h1>
{/if}
