<script lang="ts">
  import PocketBase from "pocketbase";
  import { PUBLIC_PB_HOST } from "$env/static/public";

  const pb = new PocketBase(PUBLIC_PB_HOST);

  if (typeof document !== "undefined") {
    pb.authStore.loadFromCookie(document.cookie);
    pb.authStore.onChange(() => {
      document.cookie = pb.authStore.exportToCookie({ httpOnly: false });
    });
  }

  async function login() {
    try {
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
    } catch (err) {
      console.error(err);
    }
  }

  function logout() {
    pb.authStore.clear();
    document.cookie = pb.authStore.exportToCookie({ httpOnly: false });
  }
</script>

<button on:click={login}>Logg inn med Google</button>
<button on:click={logout}>Logg ut</button>
