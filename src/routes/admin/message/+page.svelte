<script lang="ts">
  import { pb } from "$lib/stores/authStore";

  let { data } = $props();
  let displayMessages = $state(data.displayMessages);
  let activeMessage = data.activeMessage[0];

  let messageVisible = $state(activeMessage.isVisible);
  async function updateActiveMessage() {
    await pb.collection("activeMessage").update(activeMessage.id, {
      message: selectedDisplayMessage.id,
      isVisible: messageVisible
    });
  }

  let selectedDisplayMessage = $state({ id: activeMessage.message });

  async function updateDisplayMessages() {
    updateActiveMessage();
    for (let screnMessage of displayMessages) {
      await pb.collection("displayMessages").update(screnMessage.id, {
        title: screnMessage.title,
        subtext: screnMessage.subtext
      });
    }
  }
</script>

<form>
  <ul class="list-none">
    {#each displayMessages as displayMessage}
      <div class="flex">
        <div class="form-control">
          <label class="label cursor-pointer">
            <input
              type="radio"
              name="selected"
              class="radio mr-2 mt-4"
              checked={displayMessage.id == selectedDisplayMessage.id}
              onchange={() => {
                selectedDisplayMessage = displayMessage;
                messageVisible = true;
              }}
            />

            <li>
              <input
                type="text"
                placeholder="Tittel"
                bind:value={displayMessage.title}
                class="input input-lg input-bordered w-full max-w-xs"
              />
            </li>

            <li>
              <input
                type="text"
                placeholder="Beskrivelse"
                bind:value={displayMessage.subtext}
                class="input input-lg input-bordered ml-4 w-full max-w-xs"
              />
            </li>
          </label>
        </div>
      </div>
    {/each}

    <input
      type="radio"
      name="selected"
      class="radio mr-2 mt-4"
      checked={!messageVisible}
      onchange={() => (messageVisible = false)}
    />
    <span class="text-lg">Åpent!</span>
  </ul>

  <button type="submit" class="btn mt-4 w-full max-w-xs" onclick={updateDisplayMessages}
    >Lagre</button
  >
</form>
