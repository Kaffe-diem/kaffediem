<script lang="ts">
  import { onMount } from "svelte";
  import { logout } from "$stores/auth";
  import { goto } from "$app/navigation";
  import { resolve } from "$app/paths";

  onMount(async () => {
    await logout();
    goto(resolve("/"));
  });
</script>
