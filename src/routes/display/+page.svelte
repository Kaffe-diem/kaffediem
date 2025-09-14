<script lang="ts">
  import OrderList from "./OrderList.svelte";
  import { OrderStateOptions } from "$lib/pocketbase";
  import { status } from "$stores/statusStore";
  const { received, production, completed } = OrderStateOptions;
</script>

<div class="flex flex-col">
  {#if $status.message.title && $status.message.subtitle}
    <div class="grid grid-cols-[1fr_auto_1fr] items-center text-center text-3xl">
      <div class="pr-4 text-right">{$status.message.title}</div>
      <div>ー</div>
      <div class="pl-4 text-left">{$status.message.subtitle}</div>
    </div>
  {:else}
    <div class="text-center text-3xl">
      {$status.message.title || $status.message.subtitle}
    </div>
  {/if}
  <div
    class="grid h-full grid-cols-1 grid-rows-[1fr_auto_1fr] md:grid-cols-[1fr_auto_1fr] md:grid-rows-1"
  >
    <OrderList show={[received, production]} label="Straks ferdig..." class="bg-base-200" />

    <div class="divider md:divider-horizontal"></div>

    <OrderList show={[completed]} label="Kom og hent!" class="bg-primary text-base-100" />
  </div>
</div>
