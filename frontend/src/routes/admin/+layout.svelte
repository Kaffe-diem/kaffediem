<script>
  import BackButton from "$components/BackButton.svelte";
  let { children } = $props();
</script>

<main class="relative mx-auto w-full">
  {@render children?.()}
</main>

<div class="fixed right-0 bottom-0 m-4 flex flex-row gap-2">
  <BackButton />
</div>
