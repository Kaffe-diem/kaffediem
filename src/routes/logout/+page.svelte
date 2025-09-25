<script lang="ts">
  import { onMount } from "svelte";
  import { logout } from "$stores/authStore";
  import { goto } from "$app/navigation";
  import { resolve } from "$app/paths";

  onMount(() => {
    logout();
    goto(resolve("/"));
  });
</script>
