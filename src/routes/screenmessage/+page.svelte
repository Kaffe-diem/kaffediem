<script lang="ts">
  import { pb } from "$lib/stores/authStore";
  import { onMount } from "svelte";

  export let data: { screenMessageRecord };
  let screenMessage = data.screenMessageRecord[0];

  onMount(() => {
    pb.collection("screen_message").subscribe("*", function (event) {
      screenMessage = event.record;
    });
  });
</script>

<div class="flex">
  <input
    type="text"
    placeholder="Tittel"
    value={screenMessage.title}
    class="input input-lg input-bordered w-full max-w-xs"
  />

  <input
    type="text"
    placeholder="Beskrivelse"
    value={screenMessage.subtext}
    class="input input-lg input-bordered ml-4 w-full max-w-xs"
  />
</div>
<button class="btn mt-4 w-full max-w-xs">OK</button>
