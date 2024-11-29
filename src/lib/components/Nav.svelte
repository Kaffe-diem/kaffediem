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

  const navItems = [new NavItem("/account", "Min bruker"), new NavItem("/admin", "Admin")];
</script>

<div class="drawer drawer-end z-[2]">
  <input id="drawer" type="checkbox" class="drawer-toggle" />
  <div class="drawer-content flex flex-col">
    <div class="navbar w-full">
      <div class="flex-1">
        <a href="/" class="btn btn-ghost text-xl">Kaffe Diem</a>
      </div>
      <div class="flex-none lg:hidden">
        <label for="drawer" aria-label="open sidebar" class="btn btn-square btn-ghost">
          <MenuIcon />
        </label>
      </div>
      <div class="hidden flex-none lg:block">
        <ul class="menu menu-horizontal">
          <NavItems
            {navItems}
            isAuthenticated={$auth.isAuthenticated}
            isAdmin={$auth.user?.is_admin}
            class="menu menu-horizontal px-1"
          />
        </ul>
      </div>
    </div>
  </div>
  <div class="drawer-side">
    <label for="drawer" aria-label="close sidebar" class="drawer-overlay"></label>
    <ul class="menu min-h-full w-80 bg-base-100 p-4">
      <NavItems
        {navItems}
        isAuthenticated={$auth.isAuthenticated}
        isAdmin={$auth.user?.is_admin}
        class="text-2xl"
      />
    </ul>
  </div>
</div>
