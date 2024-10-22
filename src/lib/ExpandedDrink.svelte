<script lang="ts">
  export let drink: any;
  import { pb } from "$lib/stores/authStore";
</script>

<div class="card bg-base-100 shadow-md transition-all duration-100 hover:scale-[101%] hover:shadow-lg ">
  <figure>
    <img
      class="h-16"
      src={pb.files.getUrl(drink.expand.drink, drink.expand.drink.image)}
      alt={drink.expand.drink.name}
    />
  </figure>
  <div class="card-body">
    <h2 class="card-title">{drink.expand.drink.name}</h2>
    <p>Price: ${drink.expand.drink.price}</p>
    {#if drink.serving_size}
      <p>Serving Size: {drink.serving_size}</p>
    {/if}
    {#if drink.extras}
      <p>Extras: {drink.extras}</p>
    {/if}
    {#if drink.milk}
      <p>Milk: {drink.milk}</p>
    {/if}
    {#if drink.flavor}
      <p>Flavor: {drink.flavor}</p>
    {/if}
    <div class="card-actions justify-end">
      <button class="btn btn-primary">Bestill igjen</button>
      <button class="btn btn-tertiary btn-ghost">Slett</button>
    </div>
  </div>
</div>
