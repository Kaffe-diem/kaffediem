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
  <div class="flex h-screen cursor-none flex-col items-center justify-center gap-6 text-center">
    <span class="p-4 text-[clamp(3.5rem,10vw,16rem)] leading-tight font-bold">
      {$status.message.title}
    </span>
    <span class="p-4 text-[clamp(2.5rem,6vw,9rem)] leading-tight">
      {$status.message.subtitle}
    </span>
  </div>
{:else}
  <main class="relative min-h-screen w-full cursor-none py-4">
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
