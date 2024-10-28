<script lang="ts">
  import { pb } from "$lib/stores/authStore";

  export let data: { screenMessageRecord };
  const screenMessage = data.screenMessageRecord[0];

  let title = screenMessage.title;
  let subtext = screenMessage.subtext;

  async function updateScreenMessage() {
    await pb.collection("screen_message").update("tygravi8rpcyaf6", {
      title: title,
      subtext: subtext,
      isVisible: true
    });
  }
</script>

<div class="flex">
  <input
    type="text"
    placeholder="Tittel"
    bind:value={title}
    class="input input-lg input-bordered w-full max-w-xs"
  />

  <input
    type="text"
    placeholder="Beskrivelse"
    bind:value={subtext}
    class="input input-lg input-bordered ml-4 w-full max-w-xs"
  />
</div>
<button class="btn mt-4 w-full max-w-xs" on:click={updateScreenMessage}>OK</button>
