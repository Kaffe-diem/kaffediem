<script lang="ts">
  import { goto } from "$app/navigation";
  import { resolve } from "$app/paths";
  import { login as loginUser } from "$stores/authStore";

  let email: string = "";
  let password: string = "";
  let errorMessage: string = "";
  let isSubmitting = false;

  async function login() {
    isSubmitting = true;
    errorMessage = "";

    try {
      await loginUser(email, password);
      goto(resolve("/"));
    } catch (error) {
      console.error("Login error:", error);
      errorMessage =
        error instanceof Error ? error.message : "Kunne ikke logge inn. Sjekk e-post og passord.";
    } finally {
      isSubmitting = false;
    }
  }
</script>

<div class="flex justify-center">
  <form on:submit|preventDefault={login} method="post" class="flex w-lg flex-col gap-4">
    <h1 class="mb-4 text-center text-2xl font-bold">Logg inn</h1>

    <label class="input w-full">
      <span class="label">E-post</span>
      <input
        bind:value={email}
        name="email"
        type="email"
        placeholder="mail@example.com"
        required
        disabled={isSubmitting}
      />
    </label>

    <label class="input w-full">
      <span class="label">Passord</span>
      <input
        bind:value={password}
        name="password"
        type="password"
        placeholder="Passord"
        required
        disabled={isSubmitting}
      />
    </label>

    {#if errorMessage}
      <div class="alert alert-error">
        {errorMessage}
      </div>
    {/if}

    <button type="submit" class="btn btn-primary" disabled={isSubmitting}>
      {#if isSubmitting}
        Logger inn...
      {:else}
        Logg inn
      {/if}
    </button>
  </form>
</div>
