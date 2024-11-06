<script lang="ts">
  interface Props {
    orders: any[];
    filter: boolean;
  }

  let { orders, filter }: Props = $props();
</script>

<div class="overflow-y-auto">
  <ul class="flex-col">
    {#each orders as order}
      {#if order.order_fulfilled == filter}
        <li>
          <button class="btn mt-4 w-full text-xl font-normal md:btn-lg md:text-3xl">
            {order.id}</button
          >
        </li>
      {/if}
    {/each}
  </ul>
</div>
