<script lang="ts">
    import QR from "$lib/assets/qr-code.svg";
</script>

<main class="h-screen relative py-4 w-11/12 mx-auto">
    <slot />
</main>
  <div class="absolute bottom-0 left-0 hidden md:flex">
    <a href="/">
      <img class="h-48 w-48" src={QR} alt="QR code"/>
    </a>
    <div class="flex flex-col items-start justify-center ml-2 mr-2 py-1 text-xl text-neutral">
      <span>Skann eller besøk</span>
      <a href="https://kaffediem.asvg.no" class="font-bold text-accent">kaffediem.asvg.no</a>
      <span>for å bestille</span>
    </div>
  </div>