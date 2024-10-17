<script lang="ts">
	import PocketBase from "pocketbase";

	const pb = new PocketBase("https://kodekafe-pocketbase.fly.dev/");
	async function onSignIn() {
		const authData = await pb.collection("users").authWithOAuth2({
			provider: "google"
		});

		const meta = authData.meta;

		if (meta?.isNew) {
			const formData = new FormData();

			const response = await fetch(meta.avatarUrl);

			if (response.ok) {
				const file = await response.blob();
				formData.append("avatar", file);
			}

			formData.append("name", meta.name);

			await pb.collection("users").update(authData.record.id, formData);
		}
	}
</script>

<header class="flex items-center justify-between">
	<h1 class="text-4xl">Kaffe Diem</h1>
	<nav>
		<ul class="flex items-center justify-between space-x-4">
			<li>
				<a href="/">Heim</a>
			</li>
			<li>
				<button on:click={onSignIn}>Logg inn</button>
			</li>
		</ul>
	</nav>
</header>
