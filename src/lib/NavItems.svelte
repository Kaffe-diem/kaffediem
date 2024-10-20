<script>
  export let navItems;
  export let isAuthenticated;
  import AuthButton from "$lib/AuthButton.svelte";
</script>

<ul class="menu {$$restProps.class || ''}">
  {#each navItems as item}
    {#if isAuthenticated || !item.requiresAuth}
      <li>
        <a href={item.href}>{item.text}</a>
      </li>
    {/if}
  {/each}
  <li><AuthButton /></li>
</ul>
