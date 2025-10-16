<script lang="ts">
  import { status, updateStatus } from "$stores/status";
  import { type Snippet } from "svelte";
  import { resolve } from "$app/paths";
  import { get } from "svelte/store";

  interface Props {
    children: Snippet;
  }

  let { children }: Props = $props();
  const openOrders = async () => {
    const current = get(status);
    await updateStatus({ ...current, open: true });
  };
</script>

{#if $status.open}
  <main class="relative mx-auto h-dvh w-full xl:w-11/12">
    {@render children?.()}
  </main>
{:else}
  <div class="flex h-full w-full flex-col items-center justify-center">
    <span class="p-2 text-center text-3xl font-bold md:text-6xl">Det er stengt</span>
    <button
      class="btn relative m-4 flex h-24 w-1/2 flex-col items-center justify-center text-3xl lg:text-5xl
"
      onclick={openOrders}>Åpne</button
    >
    <a
      href={resolve("/admin/message")}
      class="btn relative m-4 flex h-24 w-1/2 flex-col items-center justify-center text-3xl lg:text-5xl"
      >Eller endre status</a
    >
  </div>
{/if}
