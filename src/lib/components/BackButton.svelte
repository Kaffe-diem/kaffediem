<script lang="ts">
  import { goto } from "$app/navigation";

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

<div class="fixed right-0 bottom-0 m-4 flex">
  <button onclick={goBack} class="btn btn-lg btn-secondary">Tilbake</button>
</div>
