<script lang="ts">
  import { goto } from "$app/navigation";
  import { resolve } from "$app/paths";
  import BackButton from "$assets/BackButton.svelte";

  function goBack() {
    const route = window.location.pathname;

    if (route === "/admin") {
      goto(resolve("/"));
    } else if (route.startsWith("/admin/menu/customization/")) {
      goto(resolve("/admin/menu/customization"));
    } else if (route.startsWith(resolve("/admin/menu/"))) {
      goto(resolve("/admin/menu"));
    } else {
      goto(resolve("/admin"));
    }
  }
</script>

<button onclick={goBack} class="btn btn-lg btn-secondary"><BackButton /></button>
