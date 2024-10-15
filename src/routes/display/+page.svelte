<script>
  import OrderItem from "$lib/OrderItem.svelte";
</script>

<div class = "grid grid-cols-1 md:grid-cols-2 gap-4 h-screen">
  <div class="p-4 h-full flex flex-col border-b-2 md:border-b-0 md:border-r-2 border-black">
    <h2 class="mb-3 md:mb-6 text-3xl md:text-4xl md:text-center font-bold">Straks ferdig...</h2>
    <div class="flex flex-wrap gap-2">
      <OrderItem>123</OrderItem>
      <OrderItem>456</OrderItem>
      <OrderItem>789</OrderItem>
    </div>
  </div>
  <div class="p-4 h-full flex flex-col">
    <h2 class="mb-3 md:mb-6 text-3xl md:text-4xl md:text-center text-green-700 font-bold">Kom og hent!</h2>
    <div class="flex flex-wrap gap-2">
      <OrderItem>123</OrderItem>
      <OrderItem>456</OrderItem>
      <OrderItem>789</OrderItem>
    </div>
  </div>
</div>
