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

<img src={Logo} alt="Kaffe diem logo" class="w-full max-w-[400px] md:max-w-[300px] md:float-left m-4 mx-auto" />

<h1 class="text-4xl">Kaffe diem</h1>

Vi lager veldig god kaffe!

<br />

<a href="/drinks" class="link-primary">Se menyen vår</a>

{#if isAuthenticated}
  <a href="/drinks" class="btn">Trykk her for å bestille</a>
{:else}
  <AuthButton class="btn m-2">Logg inn for å bestille</AuthButton>
  <p class="text-xs">Ved å opprette en bruker samtykker du til våre <a href="/tos" class="link-primary">vilkår for bruk</a></p>
{/if}
