<script>
  import BackButton from "$components/BackButton.svelte";

  let { children } = $props();
</script>

<main class="relative mx-auto w-full">
  {@render children?.()}
</main>

<BackButton />
