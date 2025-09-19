<script lang="ts">
  import { status } from "$stores/statusStore";
  import { type Snippet } from "svelte";

  // import QR from "$assets/qr-code.svg";

  interface Props {
    children: Snippet;
  }

  let { children }: Props = $props();
</script>

{#if $status.showMessage && ($status.message.title || $status.message.subtitle)}
  <div
    class="flex {$status.open
      ? 'h-1/3 justify-start pt-20'
      : 'h-screen justify-center'} bg-base-100 fixed bottom-0 z-100 w-full cursor-none flex-col items-center text-center"
  >
    <span class="p-2 text-7xl font-bold md:text-9xl">
      {$status.message.title || $status.message.subtitle}
    </span>
    <span class="p-2 text-4xl md:text-6xl">
      {$status.message.subtitle && $status.message.title && $status.message.subtitle}
    </span>
  </div>
{/if}

<main class="relative min-h-screen w-full cursor-none py-4">
  {@render children?.()}
</main>

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
