<script>
  import "../app.css";
  import { page } from "$app/stores";
  import Nav from "$lib/Nav.svelte";
</script>

<!-- Display-kiosk-siden skal ikke ha noen navbar; den skal kun vise bestillinger -->
{#if $page.url.pathname.includes("display")}
  <slot />
{:else}
  <div class="app mx-auto w-11/12 md:w-9/12">
    <Nav />
    <main class="mt-16">
      <slot />
    </main>
  </div>
{/if}
