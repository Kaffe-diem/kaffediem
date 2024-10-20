<script>
  import { auth } from "$lib/stores/authStore";
  import { onMount } from "svelte";
  import Logo from "$lib/assets/logo.png";
  import AuthButton from "$lib/AuthButton.svelte";

  let isAuthenticated = false;

  onMount(auth.subscribe((value) => {
    isAuthenticated = value.isAuthenticated;
  }));
</script>

<img src={Logo} alt="Kaffe diem logo" class="w-full max-w-[400px] md:max-w-[300px] md:pr-5 md:float-left m-4 mx-auto" />

<h1 class="text-4xl">Kaffe diem</h1>

<p>
  Den beste kaffeen på amalie skram!
</p>

<div class="inline-block text-center m-2">
  <div class="rating rating-lg rating-half">
    {#each Array(10) as _, n}
      <input type="radio" class="mask mask-star-2 {n % 2 == 0 ? 'mask-half-1' : 'mask-half-2'} bg-primary" checked={n == 8} disabled />
    {/each}
  </div>
  <br />
  <span class="text-sm">Fra 1729 omtaler</span>
</div>

<!-- Jump below the image -->
<br class="clear-both" />

<div class="card bg-base-200 w-full md:max-w-lg shadow">
  <div class="card-body">
    <h2 class="card-title">Meningen med livet</h2>
    <div class="rating rating-half block">
      {#each Array(10) as _, n}
        <input type="radio" class="mask mask-star-2 {n % 2 == 0 ? 'mask-half-1' : 'mask-half-2'} bg-primary" checked={n == 9} disabled />
      {/each}
    </div>
    <p>Dette er den beste kaffeen jeg noen gang har smakt!</p>
    <p class="mt-2 italic">- Navn Navnesen</p>
  </div>
</div>

<br />

<p>
  <a href="/drinks" class="link-primary">Se menyen vår</a>
</p>

<br />

{#if isAuthenticated}
  <a href="/drinks" class="btn">Trykk her for å bestille</a>
{:else}
  <AuthButton class="btn m-2">Logg inn for å bestille</AuthButton>
  <p class="text-xs">Ved å opprette en bruker samtykker du til våre <a href="/tos" class="link-primary">vilkår for bruk</a></p>
{/if}
