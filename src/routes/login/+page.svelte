<script lang="ts">
  import pb from "$lib/pocketbase";
  import { Collections } from "$lib/pocketbase";
  import type { ClientResponseError } from "pocketbase";
  import { goto } from "$app/navigation";

  let email, password, errorMessage;

  async function login() {
    try {
      await pb.collection(Collections.User).authWithPassword(email, password);

      document.cookie = pb.authStore.exportToCookie({
        path: "/",
        httpOnly: false,
        sameSite: "lax",
        secure: process.env.NODE_ENV === "production",
        maxAge: 60 * 60 * 24 * 7 // 7 days
      });
      goto("/");
    } catch (e) {
      const error = e as ClientResponseError;
      console.error(error);
      errorMessage = e.message;
    }
  }
</script>

<div class="flex justify-center">
  <form on:submit|preventDefault={login} method="post" class="flex w-lg flex-col gap-4">
    <label class="input w-full">
      <span class="label">Mail</span>
      <input bind:value={email} name="email" type="email" placeholder="mail@example.com" />
    </label>

    <label class="input w-full">
      <span class="label">Passord</span>
      <input bind:value={password} name="password" type="password" placeholder="Passord" />
    </label>

    {#if errorMessage}
      <div>
        {errorMessage}
      </div>
    {/if}

    <button type="submit" class="btn">Logg inn</button>
  </form>
</div>
