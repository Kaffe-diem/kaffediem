<script lang="ts">
  import type { NavItem } from "$lib/types";
  import AuthButton from "$components/AuthButton.svelte";

  interface Props {
    navItems: NavItem[];
    isAuthenticated: boolean;
    isAdmin: boolean;
    class?: string;
  }

  let { navItems, isAuthenticated, isAdmin, class: className = "" }: Props = $props();
</script>

<ul class="menu {className}">
  {#each navItems as item}
    {#if (isAuthenticated || !item.requiresAuth) && (isAdmin || !item.requiresAdmin)}
      <li>
        <a href={item.href} tabindex="0">{item.text}</a>
      </li>
    {/if}
  {/each}
  <li><AuthButton /></li>
</ul>
