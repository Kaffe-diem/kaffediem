<script>
  let { children } = $props();
</script>

<main class="relative mx-auto w-11/12 py-4">
  {@render children?.()}
</main>

<div class="fixed right-0 bottom-0 m-8 hidden md:flex">
  <a href="/admin" class="btn btn-secondary">Tilbake</a>
</div>
