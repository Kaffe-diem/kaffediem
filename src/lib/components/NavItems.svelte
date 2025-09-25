<script lang="ts">
  import type { NavItem } from "$lib/types";
  import AuthButton from "$components/AuthButton.svelte";
  import { resolve } from "$app/paths";

  interface Props {
    navItems: NavItem[];
    isAuthenticated: boolean;
    isAdmin: boolean;
    class?: string;
  }

  let { navItems, isAuthenticated, isAdmin, class: className = "" }: Props = $props();
</script>

<ul class="menu {className}">
  {#each navItems as item (item.href)}
    {#if (isAuthenticated || !item.requiresAuth) && (isAdmin || !item.requiresAdmin)}
      <li>
        <a href={resolve(item.href)} tabindex="0">{item.text}</a>
      </li>
    {/if}
  {/each}
  <li><AuthButton /></li>
</ul>
