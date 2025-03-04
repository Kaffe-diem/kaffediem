<script lang="ts">
  import { Item } from "$lib/types";
  let { selectedItem } = $props();
  import order from "$stores/orderStore";
  import auth from "$stores/authStore";

  let cart = $state<Item[]>([]);
  let totalPrice = $derived(cart.reduce((sum, item) => sum + item.price, 0));
</script>

<div class="flex h-full flex-col justify-center gap-8">
  <ul>
    <label><input type="checkbox" class="toggle" /> Bursdag</label>
    <label><input type="checkbox" class="toggle" /> Klippekort</label>

    <fieldset>
      <legend>Melk</legend>
      <label><input type="radio" class="radio" name="milk" /> Havre</label>
      <label><input type="radio" class="radio" name="milk" /> Soya</label>
      <label><input type="radio" class="radio" name="milk" /> Hel</label>
    </fieldset>

    <fieldset>
      <legend>Smaker</legend>
      <label><input type="radio" class="radio" name="flavor" /> Vanilje</label>
      <label><input type="radio" class="radio" name="flavor" /> Salt karamell</label>
      <label><input type="radio" class="radio" name="flavor" /> Pumpkin spice</label>
    </fieldset>

    <fieldset>
      <legend>Extra</legend>
      <label><input type="radio" class="radio" name="extra" /> Sirup</label>
      <label><input type="radio" class="radio" name="extra" /> Krem</label>
      <label><input type="radio" class="radio" name="extra" /> Espresso</label>
    </fieldset>

    <fieldset>
      <legend>Kopp</legend>
      <label><input type="radio" class="radio" name="size" /> Liten</label>
      <label><input type="radio" class="radio" name="size" /> Middels</label>
      <label><input type="radio" class="radio" name="size" /> Stor</label>
      <label><input type="radio" class="radio" name="size" /> Egen</label>
    </fieldset>
  </ul>

  <div class="h-1/2 overflow-y-auto">
    <table class="table table-pin-rows table-auto list-none p-4 shadow-2xl">
      <thead>
        <tr>
          <th class="w-full">Drikke</th>
          <th class="whitespace-nowrap">Pris</th>
        </tr>
      </thead>
      <tbody>
        {#if cart.length > 0}
          {#each cart as item, index}
            <tr class="hover select-none" onclick={() => cart.splice(index, 1)}>
              <td>{item.name}</td>
              <td>{item.price},-</td>
            </tr>
          {/each}
        {:else}
          <tr>
            <td>Ingenting</td>
            <td></td>
          </tr>
        {/if}
      </tbody>
      <tfoot>
        <tr>
          <th>Total: <span class="text-neutral">{cart.length}</span></th>
          <th><span class="text-bold text-lg text-primary">{totalPrice},-</span></th>
        </tr>
      </tfoot>
    </table>
  </div>

  <div class="flex flex-row justify-center gap-2">
    <button
      class="bold btn btn-lg text-xl"
      onclick={() => {
        order.create(
          $auth.user.id,
          cart.map((item) => item.id)
        );
        cart = [];
      }}>Ferdig</button
    >
    <button
      class="bold btn btn-primary btn-lg text-3xl"
      onclick={() => cart.push(selectedItem as Item)}>+</button
    >
  </div>
</div>
