<script lang="ts">
  import { onMount } from "svelte";
  import { auth, pb } from "$lib/stores/authStore";
  import { goto } from "$app/navigation";

  let isAuthenticated = false;

  onMount(auth.subscribe((value) => {
    isAuthenticated = value.isAuthenticated;
  }));

  if (typeof document !== "undefined") {
    pb.authStore.loadFromCookie(document.cookie);
    pb.authStore.onChange(() => {
      document.cookie = pb.authStore.exportToCookie({ httpOnly: false });
    });
  }

  function goHome() {
    if (window.location.pathname === '/') {
      window.location.reload();
    } else {
      goto('/');
    }
  }

  async function login() {
    const authData = await pb.collection("users").authWithOAuth2({ provider: "google" });

    const meta = authData.meta;

    if (meta?.isNew) {
      const formData = new FormData();
      formData.append("name", meta.name);

      const response = await fetch(meta.avatarUrl);
      if (response.ok) {
        const file = await response.blob();
        formData.append("avatar", file);
      }

      await pb.collection("users").update(authData.record.id, formData);
    }

    document.cookie = pb.authStore.exportToCookie({ httpOnly: false });
    goHome()
  }

  function logout() {
    pb.authStore.clear();
    document.cookie = pb.authStore.exportToCookie({ httpOnly: false });
    goHome()
  }
</script>

{#if isAuthenticated}
  <button on:click={logout} class="hover:underline">Logg ut</button>
{:else}
  <button on:click={login} class="hover:underline">Logg inn</button>
{/if}
