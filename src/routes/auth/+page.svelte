<script lang="ts">
  import PocketBase from "pocketbase";
  import { PUBLIC_PB_HOST } from "$env/static/public";

  const pb = new PocketBase(PUBLIC_PB_HOST);

  async function login(form: HTMLFormElement) {
    try {
      await pb.collection("users").authWithOAuth2({ provider: "google" });
      form.token.value = pb.authStore.token;
      form.submit();
    } catch (err) {
      console.error(err);
    }
  }
</script>

<form method="post" on:submit|preventDefault={(e) => login(e.currentTarget)}>
  <input name="token" type="hidden" />
  <button>Login using Google</button>
</form>
