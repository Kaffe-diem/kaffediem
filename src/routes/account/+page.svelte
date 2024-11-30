<script lang="ts">
  import { userOrders } from "$stores/orderStore";
  import auth from "$stores/authStore";
  import MenuItem from "$components/MenuItem.svelte";
  import Status from "./Status.svelte";
</script>

{#if $auth.isAuthenticated}
  <h1 class="mb-4 flex items-center text-2xl">
    Hei, {$auth.user.name}{#if $auth.user.is_admin}<span class="badge badge-primary badge-lg ml-2"
        >Admin</span
      >{/if}
  </h1>

  <Status />

  <h2 class="mb-4 text-xl">Tidligere bestillinger:</h2>

  {#each $userOrders as order}
    <div class="mb-4 grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4">
      {#each order.drinks as item}
        <MenuItem item={item.item} buyButton />
      {/each}
    </div>
  {/each}
{:else}
  <h1 class="text-2xl">Du er ikke logget inn!</h1>
{/if}
