<script lang="ts">
	import OrderList from "$lib/OrderList.svelte";
	import { State, Order } from "$lib/types";
	import PocketBase from "pocketbase";

	$: orders = [new Order(123), new Order(456), new Order(789, State.Complete)];

	const pb = new PocketBase("https://kodekafe-pocketbase.fly.dev/");
</script>

<div class="grid h-screen grid-cols-1 gap-4 md:grid-cols-2">
	<div class="flex h-full flex-col border-b-2 border-black p-4 md:border-b-0 md:border-r-2">
		https://github.com/creekdrops/svelte-pocketbase
		<h2 class="mb-3 text-3xl font-bold md:mb-6 md:text-center md:text-4xl">Straks ferdig...</h2>
		<OrderList {orders} filter={State.Production} />
	</div>
	<div class="flex h-full flex-col p-4">
		<h2 class="mb-3 text-3xl font-bold text-green-700 md:mb-6 md:text-center md:text-4xl">
			Kom og hent!
		</h2>
		<OrderList {orders} filter={State.Complete} />
	</div>
</div>
