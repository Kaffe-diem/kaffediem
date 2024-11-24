<script lang="ts">
  import { userOrders } from "$stores/orderStore";
  import auth from "$stores/authStore";
</script>

{#if $auth.isAuthenticated}
  <h1 class="mb-4 flex items-center text-2xl">
    Hei, {$auth.user.name}{#if $auth.user.is_admin}<span class="badge badge-primary badge-lg ml-2"
        >Admin</span
      >{/if}
  </h1>

  <h2 class="mb-4 text-xl">Tidligere bestillinger:</h2>

  {#each $userOrders as order}
    <div class="mb-4 grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4">
      {#each order.drinks as item}
        <div class="card card-compact m-2 bg-base-200">
          <figure>
            <img
              class="h-48 w-full object-cover"
              src={item.item.image}
              alt={`Bilde av ${item.item.name}`}
            />
          </figure>
          <div class="card-body">
            <h2 class="card-title">{item.item.name}</h2>
            <div class="card-actions items-center justify-between">
              <span class="ml-auto">{item.item.price},-</span>
            </div>
          </div>
        </div>
      {/each}
    </div>
  {/each}
{:else}
  <h1 class="text-2xl">Du er ikke logget inn!</h1>
{/if}
