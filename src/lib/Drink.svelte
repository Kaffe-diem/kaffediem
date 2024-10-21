<script lang="ts">
  export let favorite: any;
  import { pb } from "$lib/stores/authStore";
</script>

<div class="card bg-base-100 shadow-md transition-all duration-100 hover:scale-[101%] hover:shadow-lg ">
  <figure>
    <img
      class=""
      src={pb.files.getUrl(favorite.expand.drink, favorite.expand.drink.image)}
      alt={favorite.expand.drink.name}
    />
  </figure>
  <div class="card-body">
    <h2 class="card-title">{favorite.expand.drink.name}</h2>
    <p>Price: ${favorite.expand.drink.price}</p>
    <p>Serving Size: {favorite.serving_size}</p>
    <p>Extras: {favorite.extras}</p>
    <p>Milk: {favorite.milk}</p>
    <p>Flavor: {favorite.flavor}</p>
    <div class="card-actions justify-end">
      <button class="btn btn-primary">Bestill igjen</button>
      <button class="btn btn-tertiary btn-ghost">Slett</button>
    </div>
  </div>
</div>
