<script lang="ts">
  import { toasts } from "$lib/stores/toastStore";
  import { fade } from "svelte/transition";
</script>

<div class="toast toast-end toast-top z-50">
  {#each $toasts as toast (toast.id)}
    <div class="alert alert-{toast.type} opacity-90" transition:fade={{ duration: 100 }}>
      <button class="text-8xl font-bold" on:click={() => toasts.remove(toast.id)}
        >{toast.message}</button
      >
    </div>
  {/each}
</div>
