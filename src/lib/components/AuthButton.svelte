<script lang="ts">
  import auth from "$stores/authStore";
  import { resolve } from "$app/paths";

  interface Props {
    children?: import("svelte").Snippet;
    class?: string;
  }

  let { children, class: className = "" }: Props = $props();
</script>

{#if $auth.isAuthenticated}
  <a href={resolve("/logout")} class={className}
    >{#if children}{@render children()}{:else}Logg ut{/if}</a
  >
{:else}
  <a href={resolve("/login")} class={className}
    >{#if children}{@render children()}{:else}Logg inn{/if}</a
  >
{/if}
