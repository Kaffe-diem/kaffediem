<script lang="ts">
  import { status } from "$stores/statusStore";
  import { type Snippet } from "svelte";

  // import QR from "$assets/qr-code.svg";

  interface Props {
    children: Snippet;
  }

  let { children }: Props = $props();
</script>

{#if $status?.online}
  <div class="flex h-screen flex-col items-center justify-center text-center">
    <span class="p-2 text-7xl font-bold md:text-9xl">{$status.message.title}</span>
    <span class="p-2 text-4xl md:text-6xl">{$status.message.subtitle}</span>
  </div>
{:else}
  <main class="relative mx-auto h-screen w-11/12 py-4">
    {@render children?.()}
  </main>
{/if}

<!-- <div class="absolute bottom-0 left-0 hidden md:flex">
  <a href="/">
    <img class="h-48 w-48" src={QR} alt="QR code" />
  </a>
  <div class="ml-2 mr-2 flex flex-col items-start justify-center py-1 text-xl text-neutral">
    <span>Skann eller besøk</span>
    <a href="https://kaffediem.asvg.no" class="font-bold text-accent">kaffediem.asvg.no</a>
    <span>for å bestille</span>
  </div>
</div> -->
