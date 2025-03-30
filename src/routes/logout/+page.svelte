<script lang="ts">
  import { onMount } from "svelte";
  import { logout } from "$stores/authStore";
  import { goto } from "$app/navigation";

  onMount(() => {
    logout();
    goto("/");
  });
</script>
