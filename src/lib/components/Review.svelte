<script lang="ts">
  import Rating from "$components/Rating.svelte";
  export let rating: number;
</script>

<div class="card m-2 w-full flex-none bg-base-200 shadow md:max-w-lg">
  <div class="card-body">
    <h2 class="card-title"><slot name="title">Title</slot></h2>
    <Rating value={rating} readonly />
    <p><slot name="content">Content</slot></p>
    <p class="mt-2 italic">- <slot name="author">Author</slot></p>
  </div>
</div>
