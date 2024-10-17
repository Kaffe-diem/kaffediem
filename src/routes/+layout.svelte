<script>
  import "../app.css";
  import { page } from '$app/stores';  

  const navItems = [
    { href: "/drinks", text: "Meny" },
    { href: "/display", text: "Visning" }
  ];
</script>

{#if $page.url.pathname.includes("display")}
  <slot />
{:else}
  <div class="app mx-auto w-8/12">
    <header class="flex items-center justify-between py-2">
      <h1 class="text-4xl font-bold">
        <a href="/">Kaffe Diem</a>
      </h1>
      <nav>
        <ul class="flex items-center space-x-4">
          {#each navItems as item}
            <li>
              <a href={item.href} class="hover:underline">{item.text}</a>
            </li>
          {/each}
        </ul>
      </nav>
    </header>
    <main class="mt-16">
      <slot />
    </main>
  </div>
{/if}
