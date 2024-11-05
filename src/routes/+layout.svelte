<script>
  import "../app.css";
  import { page } from "$app/stores";
  import Nav from "$components/Nav.svelte";
  import Footer from "$components/Footer.svelte";

  import { hideNavbar, hideFooter } from "$lib/constants.ts";
</script>

<div class="grid min-h-screen grid-rows-[1fr_auto]">
  {#if hideNavbar.includes($page.url.pathname)}
    <slot />
  {:else}
    <div class="app mx-auto grid w-11/12 grid-rows-[auto_1fr] md:w-9/12">
      <Nav />
      <main class="mt-16">
        <slot />
      </main>
    </div>
  {/if}

  {#if !hideFooter.includes($page.url.pathname)}
    <Footer />
  {/if}
</div>
