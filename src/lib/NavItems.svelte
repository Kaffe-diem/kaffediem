<script>
  export let navItems;
  export let isAuthenticated;
</script>

<ul class="menu {$$restProps.class || ''}">
  {#each navItems as item}
    {#if isAuthenticated || !item.requiresAuth}
      <li>
        <a href={item.href}>{item.text}</a>
      </li>
    {/if}
  {/each}
</ul>
