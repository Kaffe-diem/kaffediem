<script lang="ts">
  import { goto } from "$app/navigation";
  import BackButton from "$assets/BackButton.svelte";

  function goBack() {
    const route = window.location.pathname;

    if (route === "/admin") {
      goto("/");
    } else if (route.startsWith("/admin/menu/customization/")) {
      goto("/admin/menu/customization");
    } else if (route.startsWith("/admin/menu/")) {
      goto("/admin/menu");
    } else {
      goto("/admin");
    }
  }
</script>

<button onclick={goBack} class="btn btn-lg btn-secondary"><BackButton /></button>
