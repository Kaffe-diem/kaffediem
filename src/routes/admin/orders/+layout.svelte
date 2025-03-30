<script lang="ts">
  import orders from "$stores/orderStore";
  import { status } from "$stores/statusStore";
  import { Status } from "$lib/types";
  import { type Snippet } from "svelte";

  interface Props {
    children: Snippet;
  }

  let { children }: Props = $props();
</script>

{#if $status.online}
  <div class="flex h-full w-full flex-col items-center justify-center">
    <span class="p-2 text-center text-3xl font-bold md:text-6xl">Det er stengt</span>
    <button
      class="btn relative m-4 flex h-24 w-1/2 flex-col items-center justify-center text-3xl lg:text-5xl
"
      onclick={() =>
        status.update(new Status($status.id, $status.message, $status.messages, false))}
      >Åpne</button
    >
    <a
      href="/admin/message"
      class="btn relative m-4 flex h-24 w-1/2 flex-col items-center justify-center text-3xl lg:text-5xl"
      >Eller endre status</a
    >
  </div>
{:else}
  <main class="relative mx-auto h-screen w-11/12 py-4">
    <button class="btn btn-lg" onclick={() => orders.undoLastAction()}>oops</button>
    {@render children?.()}
  </main>
{/if}
