<script>
  import auth from "$stores/auth";
  import Logo from "$assets/logo.avif";
  import AuthButton from "$components/AuthButton.svelte";
  import Menu from "./Menu.svelte";
  import { status, messages } from "$stores/status";
  import { resolve } from "$app/paths";

  const activeMessage = $derived(
    $messages.find((message) => message.id === $status.messageId) ?? {
      id: "",
      title: "",
      subtitle: ""
    }
  );
</script>

<img
  src={Logo}
  alt="logo"
  class="m-4 mx-auto w-full max-w-[400px] rounded-xl md:float-left md:mr-10 md:max-w-[280px]"
/>

<div class="text-2xl">
  <p>Den beste kaffeen på Amalie Skram VGS!</p>

  <br />
  <ul>
    {#if $status.open}
      <li>Vi er åpen!</li>
      {#if $status.showMessage}
        <br />
        <li class="font-bold">{activeMessage.title}</li>
        <li>{activeMessage.subtitle}</li>
      {/if}
    {:else}
      <li class="font-bold">{activeMessage.title}</li>
      <li>{activeMessage.subtitle}</li>
    {/if}
  </ul>
</div>

{#if !$auth.isAuthenticated}
  <div>
    <AuthButton class="btn m-2">Logg inn for å bestille</AuthButton>
    <p class="text-xs">
      Ved å opprette en bruker samtykker du til våre <a href={resolve("/tos")} class="link-primary"
        >vilkår for bruk</a
      >
    </p>
  </div>
{/if}

<!-- Jump below the image -->
<br class="clear-both" />

<Menu />
