<script>
  import { onMount } from "svelte";

  onMount(() => {
    const handleKeyDown = (event) => {
      if (event.key === "Escape") {
        window.location.href = "/";
      }
    };

    window.addEventListener("keydown", handleKeyDown);

    return () => {
      window.removeEventListener("keydown", handleKeyDown);
    };
  });
</script>

<div class="absolute bottom-0 right-0 m-1 hidden md:flex">
  <a href="/" class="btn btn-ghost text-xs text-neutral-400"
    >klikk <span class="rounded-md border p-1 text-xs font-bold border-neutral-400">esc</span> for å gå tilbake</a
  >
</div>
