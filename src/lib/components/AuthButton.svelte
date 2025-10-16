<script lang="ts">
  import auth from "$stores/auth";
  import { resolve } from "$app/paths";

  interface Props {
    children?: import("svelte").Snippet;
    class?: string;
  }

  let { children, class: className = "" }: Props = $props();

  const destination = $derived($auth.isAuthenticated ? "/logout" : "/login");
  const defaultLabel = $derived($auth.isAuthenticated ? "Logg ut" : "Logg inn");
</script>

<a href={resolve(destination)} class={className}>
  {#if children}
    {@render children()}
  {:else}
    {defaultLabel}
  {/if}
</a>
