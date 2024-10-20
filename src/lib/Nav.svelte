<script lang="ts">
  import { auth } from "$lib/stores/authStore";
  import { onMount } from "svelte";
  import { restrictedRoutes } from "$lib/constants";
  import AuthButton from "$lib/AuthButton.svelte";

  let isAuthenticated = false;

  onMount(auth.subscribe((value) => {
    isAuthenticated = value.isAuthenticated;
  }));

  class NavItem {
    href: string;
    text: string;
    requiresAuth: boolean;

    constructor(href: string, text: string) {
      this.href = href;
      this.text = text;
      this.requiresAuth = restrictedRoutes.includes(this.href);
    }
  }

  const navItems = [
    new NavItem("/drinks", "Meny"),
    new NavItem("/display", "Visning"),
    new NavItem("/account", "Min bruker"),
  ];
</script>

<div class="navbar bg-base-100">
  <div class="flex-1">
    <a href="/" class="btn btn-ghost text-xl">Kaffe Diem</a>
  </div>
  <div class="flex-none">
    <ul class="menu menu-horizontal px-1">
      {#each navItems as item}
        {#if isAuthenticated || !item.requiresAuth}
        <li>
          <a href={item.href}>{item.text}</a>
        </li>
        {/if}
      {/each}
      <li><AuthButton /></li>
    </ul>
  </div>
</div>
