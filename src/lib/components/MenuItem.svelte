<script lang="ts">
  import auth from "$stores/auth";
  import { addToCart } from "$stores/cart";
  import type { Item } from "$lib/types";

  interface Props {
    item: Item;
    buyButton: boolean;
  }

  let { buyButton, item }: Props = $props();
</script>

<div class="card card-compact bg-base-200">
  <figure>
    <img class="h-48 w-full object-cover" src={item.image} alt={`Bilde av ${item.name}`} />
  </figure>
  <div class="card-body">
    <h2 class="card-title">{item.name}</h2>
    <div class="card-actions items-center justify-between">
      {#if $auth.isAuthenticated && buyButton}
        <button class="btn btn-secondary" onclick={() => addToCart(item)}>Kjøp</button>
      {/if}
      <span class="text-primary ml-auto">{item.price},-</span>
    </div>
  </div>
</div>
