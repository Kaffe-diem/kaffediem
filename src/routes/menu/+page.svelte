<script>
  import { categories } from "$stores/menuStore";
  import orders from "$stores/orderStore";
  import auth from "$stores/authStore";
</script>

{#each $categories as category}
  <div class="mb-10">
    <h1 class="mb-4 text-3xl">{category.name}</h1>
    <div class="grid grid-cols-2 gap-4 md:grid-cols-3 lg:grid-cols-4">
      {#each category.items as item}
        <div class="card card-compact bg-base-200">
          <figure>
            <img class="h-48 w-full object-cover" src={item.image} alt={`Bilde av ${item.name}`} />
          </figure>
          <div class="card-body">
            <h2 class="card-title">{item.name}</h2>
            <div class="card-actions items-center justify-between">
              {#if $auth.isAuthenticated}
                <button class="btn btn-secondary" onclick={() => orders.create([item.id])}
                  >Kjøp</button
                >
              {/if}
              <span class="ml-auto">{item.price},-</span>
            </div>
          </div>
        </div>
      {/each}
    </div>
  </div>
{/each}
