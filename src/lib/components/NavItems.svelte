<script>
  import AuthButton from "$components/AuthButton.svelte";
  let { navItems, isAuthenticated, isAdmin, ...rest } = $props();
</script>

<ul class="menu {rest.class || ''}">
  {#each navItems as item}
    {#if (isAuthenticated || !item.requiresAuth) && (isAdmin || !item.requiresAdmin)}
      <li>
        <a href={item.href} tabindex="0">{item.text}</a>
      </li>
    {/if}
  {/each}
  <li><AuthButton /></li>
</ul>
