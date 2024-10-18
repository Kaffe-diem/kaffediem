<script lang="ts">
  import { auth } from "$lib/stores/authStore";
  import { onMount } from "svelte";
  import { protectedRoutes } from "$lib/constants";
  import AuthButton from "$lib/AuthButton.svelte";

  let isAuthenticated = false;

  onMount(auth.subscribe((value) => {
    isAuthenticated = value.isAuthenticated;
  }));

  class NavItem {
    href: string;
    text: string;

    constructor(href: string, text: string) {
      this.href = href;
      this.text = text;
    }
  }

  const navItems = [
    new NavItem("/drinks", "Meny"),
    new NavItem("/display", "Visning"),
    new NavItem("/account", "Min bruker"),
  ];
</script>

<header class="flex items-center justify-between py-2">
  <h1 class="text-4xl font-bold">
    <a href="/">Kaffe Diem</a>
  </h1>
  <nav>
    <ul class="flex items-center space-x-4">
      {#each navItems as item}
        {#if !protectedRoutes.includes(item.href) || isAuthenticated}
        <li>
          <a href={item.href} class="hover:underline">{item.text}</a>
        </li>
        {/if}
      {/each}
      <li><AuthButton /></li>
    </ul>
  </nav>
</header>
