<script lang="ts">
  import auth from "$stores/authStore";
  import pb from "$lib/pocketbase";
  import { goto } from "$app/navigation";
  interface Props {
    children?: import("svelte").Snippet;
    class?: string;
  }

  let { children, class: className = "" }: Props = $props();

  function goHome() {
    if (window.location.pathname === "/") {
      window.location.reload();
    } else {
      goto("/");
    }
  }

  async function login() {
    const authData = await pb.collection("user").authWithOAuth2({ provider: "google" });

    const meta = authData.meta;

    if (meta?.isNew) {
      const formData = new FormData();
      formData.append("name", meta.name);

      const avatarResponse = await fetch(meta.avatarUrl);
      if (avatarResponse.ok) {
        const avatar = await avatarResponse.blob();
        formData.append("avatar", avatar);
      }

      await pb.collection("user").update(authData.record.id, formData);
    }

    document.cookie = pb.authStore.exportToCookie({ httpOnly: false });
    goHome();
  }

  function logout() {
    pb.authStore.clear();
    document.cookie = pb.authStore.exportToCookie({ httpOnly: false });
    goHome();
  }
</script>

{#if $auth.isAuthenticated}
  <button onclick={logout} class={className}
    >{#if children}{@render children()}{:else}Logg ut{/if}</button
  >
{:else}
  <button onclick={login} class={className}
    >{#if children}{@render children()}{:else}Logg inn{/if}</button
  >
{/if}
