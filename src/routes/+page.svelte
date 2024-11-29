<script>
  import auth from "$stores/authStore";
  import Logo from "$assets/logo.png";
  import AuthButton from "$components/AuthButton.svelte";
  import Rating from "$components/Rating.svelte";
  import Menu from "./Menu.svelte";
</script>

<img
  src={Logo}
  alt="logo"
  class="m-4 mx-auto w-full max-w-[400px] rounded-xl md:float-left md:mr-10 md:max-w-[280px]"
/>

<p>Den beste kaffeen på Amalie Skram VGS!</p>

<div class="m-2 inline-block text-center">
  <Rating class="rating-lg" value={9} readonly />
  <span class="text-sm">Fra 1729 omtaler</span>
</div>

{#if !$auth.isAuthenticated}
  <div>
    <AuthButton class="btn m-2">Logg inn for å bestille</AuthButton>
    <p class="text-xs">
      Ved å opprette en bruker samtykker du til våre <a href="/tos" class="link-primary"
        >vilkår for bruk</a
      >
    </p>
  </div>
{/if}

<!-- Jump below the image -->
<br class="clear-both" />

<Menu />
