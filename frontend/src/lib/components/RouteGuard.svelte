<script lang="ts">
  import { goto } from "$app/navigation";
  import { page } from "$app/stores";
  import auth from "$stores/auth";
  import { restrictedRoutes, adminRoutes } from "$lib/constants";
  import { resolve } from "$app/paths";

  let { children }: { children?: import("svelte").Snippet } = $props();

  $effect(() => {
    if ($auth.isLoading || !$page?.url) return;

    const currentPath = $page.url.pathname;
    const isRestricted = restrictedRoutes.some((route) => currentPath.startsWith(route));
    const requiresAdmin = adminRoutes.some((route) => currentPath.startsWith(route));

    if (isRestricted && !$auth.isAuthenticated) {
      goto(resolve("/login"));
    } else if (requiresAdmin && !$auth.user.isAdmin) {
      goto(resolve("/"));
    }
  });
</script>

{#if children}
  {@render children()}
{/if}
