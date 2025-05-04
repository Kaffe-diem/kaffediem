<script lang="ts">
  import { toasts } from "$lib/stores/toastStore";
  import { fade } from "svelte/transition";
</script>

<div class="toast toast-end toast-top z-50">
  {#each $toasts as toast (toast.id)}
    <div class="alert alert-{toast.type}" transition:fade={{ duration: 1000 }}>
      <span class="text-xl font-bold">{toast.message}</span>
      <button class="btn btn-ghost btn-xl" on:click={() => toasts.remove(toast.id)}>×</button>
    </div>
  {/each}
</div>
