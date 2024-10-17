<script lang="ts">
  import PocketBase from "pocketbase";
  import { PUBLIC_PB_HOST } from "$env/static/public";

  const pb = new PocketBase(PUBLIC_PB_HOST);

  async function login(form: HTMLFormElement) {
    try {
      const authData = await pb.collection("users").authWithOAuth2({ provider: "google" });

      const meta = authData.meta;

      if (meta?.isNew) {
        const formData = new FormData();

        const response = await fetch(meta.avatarUrl);

        if (response.ok) {
          const file = await response.blob();
          formData.append("avatar", file);
        }

        formData.append("name", meta.name);

        await pb.collection("users").update(authData.record.id, formData);
      }
      form.token.value = pb.authStore.token;
      form.submit();
    } catch (err) {
      console.error(err);
    }
  }
</script>
