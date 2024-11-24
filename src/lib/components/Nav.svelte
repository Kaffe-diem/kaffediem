<script lang="ts">
  import auth from "$stores/authStore";
  import { restrictedRoutes, adminRoutes } from "$lib/constants";
  import MenuIcon from "$assets/MenuIcon.svelte";
  import NavItems from "$components/NavItems.svelte";

  class NavItem {
    href: string;
    text: string;
    requiresAuth: boolean;

    constructor(href: string, text: string) {
      this.href = href;
      this.text = text;
      this.requiresAuth = restrictedRoutes.includes(this.href);
      this.requiresAdmin = adminRoutes.includes(this.href);
    }
  }

  const navItems = [
    new NavItem("/menu", "Meny"),
    new NavItem("/display", "Visning"),
    new NavItem("/account", "Min bruker"),
    new NavItem("/status", "Min bestilling"),
    new NavItem("/admin", "Admin")
  ];
</script>

<div class="navbar bg-base-100">
  <div class="flex-1">
    <a href="/" class="btn btn-ghost text-xl">Kaffe Diem</a>
  </div>
  <details class="dropdown dropdown-end lg:hidden">
    <summary tabindex="0" class="btn btn-ghost">
      <MenuIcon />
    </summary>
    <NavItems
      {navItems}
      isAuthenticated={$auth.isAuthenticated}
      isAdmin={$auth.user?.isAdmin}
      class="dropdown-content z-[1] mt-3 w-52 rounded-box bg-base-100 p-2 shadow"
    />
  </details>
  <div class="hidden flex-none lg:flex">
    <NavItems
      {navItems}
      isAuthenticated={$auth.isAuthenticated}
      isAdmin={$auth.user?.isAdmin}
      class="menu menu-horizontal px-1"
    />
  </div>
</div>
