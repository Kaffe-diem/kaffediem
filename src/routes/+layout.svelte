<script>
  import "../app.css";
  import { page } from "$app/stores";
  import Nav from "$components/Nav.svelte";
  import Footer from "$components/Footer.svelte";
  import Toast from "$components/Toast.svelte";

  import { hideNavbar, hideFooter } from "$lib/constants";

  import { onMount } from "svelte";
  import { writable, get } from "svelte/store";

  const isOnline = writable(true);

  function updateOnlineStatus() {
    const status = navigator.onLine;
    if (status && !get(isOnline)) {
      console.log("Resetting stores!");
    }
    isOnline.set(navigator.onLine);
  }

  onMount(updateOnlineStatus);

  let { children } = $props();
</script>

<svelte:window on:online={updateOnlineStatus} on:offline={updateOnlineStatus} />

{#if !$isOnline}
  <div
    class="bg-base-100/50 fixed top-0 left-0 z-99 grid h-screen w-screen place-items-center backdrop-blur-sm"
  >
    <div class="flex flex-col items-center gap-8">
      <span class="text-6xl">Mangler internett</span>
      <span class="text-xl">Venter på internetttilkobling</span>
    </div>
  </div>
{/if}

<div class="grid min-h-screen grid-rows-[1fr_auto]">
  {#if hideNavbar.some((path) => $page.url.pathname.includes(path))}
    {@render children?.()}
  {:else}
    <div class="app mx-auto grid w-11/12 grid-rows-[auto_1fr] md:w-9/12">
      <Nav />
      <main class="mt-16">
        {@render children?.()}
      </main>
    </div>
  {/if}

  {#if !hideFooter.some((path) => $page.url.pathname.includes(path))}
    <Footer />
  {/if}
</div>

<Toast />
