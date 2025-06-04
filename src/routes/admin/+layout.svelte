<script>
  import BackButton from "$components/BackButton.svelte";

  let { children } = $props();
</script>

<main class="relative mx-auto w-11/12">
  {@render children?.()}
</main>

<BackButton />
