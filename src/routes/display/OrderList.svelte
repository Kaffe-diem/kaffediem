<script lang="ts">
  import orders from "$stores/orderStore";
  import { flip } from "svelte/animate";
  import { cubicOut } from "svelte/easing";
  import type { CrossfadeParams, TransitionConfig } from "svelte/transition";
  import type { OrderStateOptions } from "$lib/pocketbase";

  type CrossfadeFn = (
    node: Element,
    params: CrossfadeParams & { key: unknown }
  ) => () => TransitionConfig;

  interface Props {
    show: OrderStateOptions[];
    label: string;
    class?: string;
    transitionSend: CrossfadeFn;
    transitionReceive: CrossfadeFn;
  }

  let {
    show,
    label = "",
    class: className = "",
    transitionSend,
    transitionReceive
  }: Props = $props();
</script>

<div class="flex h-full flex-col p-4 select-none">
  {#if label != ""}
    <h2
      class="mb-4 text-[clamp(1.75rem,3vw,4.25rem)] leading-tight font-bold md:mb-6 md:text-center"
    >
      {label}
    </h2>
  {/if}
  <div
    class="grid max-h-full grid-cols-[repeat(auto-fit,_minmax(2.5em,_1fr))] gap-4 overflow-x-hidden overflow-y-scroll text-[clamp(3rem,4vw,12rem)]"
  >
    {#each $orders.filter((order) => show.includes(order?.state)) as order (order.id)}
      <div
        class="{className} rounded-xl px-[0.2em] py-[0.2em] text-center leading-none font-bold"
        in:transitionReceive|local={{ key: order.id }}
        out:transitionSend|local={{ key: order.id }}
        animate:flip={{ duration: 225, easing: cubicOut }}
      >
        {order.dayId}
      </div>
    {/each}
  </div>
</div>
