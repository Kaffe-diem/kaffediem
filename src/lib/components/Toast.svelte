<script lang="ts">
  import { toasts } from "$lib/stores/toastStore";
  import { fade } from "svelte/transition";
</script>

<div class="toast toast-top toast-end z-50">
  {#each $toasts as toast (toast.id)}
    <div class="alert alert-{toast.type}" 
         transition:fade={{ duration: 300 }}>
      <span>{toast.message}</span>
      <button class="btn btn-ghost btn-xs" on:click={() => toasts.remove(toast.id)}>×</button>
    </div>
  {/each}
</div> 