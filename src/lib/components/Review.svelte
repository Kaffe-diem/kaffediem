<script lang="ts">
  import Rating from "$components/Rating.svelte";
  interface Props {
    rating: number;
    title?: import("svelte").Snippet;
    content?: import("svelte").Snippet;
    author?: import("svelte").Snippet;
  }

  let { rating, title, content, author }: Props = $props();
</script>

<div class="card m-2 w-full flex-none bg-base-200 shadow md:max-w-lg">
  <div class="card-body">
    <h2 class="card-title">
      {#if title}{@render title()}{:else}Title{/if}
    </h2>
    <Rating value={rating} readonly />
    <p>
      {#if content}{@render content()}{:else}Content{/if}
    </p>
    <p class="mt-2 italic">
      - {#if author}{@render author()}{:else}Author{/if}
    </p>
  </div>
</div>
