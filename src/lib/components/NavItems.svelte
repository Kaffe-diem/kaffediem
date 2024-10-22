<script>
  export let navItems;
  export let isAuthenticated;
  import AuthButton from "$components/AuthButton.svelte";
</script>

<ul class="menu {$$restProps.class || ''}">
  {#each navItems as item}
    {#if isAuthenticated || !item.requiresAuth}
      <li>
        <a href={item.href} tabindex="0">{item.text}</a>
      </li>
    {/if}
  {/each}
  <li><AuthButton /></li>
</ul>
