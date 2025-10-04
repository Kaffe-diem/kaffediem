<script lang="ts">
  import { goto } from "$app/navigation";
  import { resolve } from "$app/paths";
  import { login as loginUser } from "$stores/authStore";

  let email: string = "";
  let password: string = "";
  let errorMessage: string = "";

  async function login() {
    try {
      await loginUser(email, password);
      goto(resolve("/"));
    } catch (error) {
      errorMessage = error instanceof Error ? error.message : "Kunne ikke logge inn";
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
