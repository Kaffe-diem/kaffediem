<script lang="ts">
  import { pb } from "$lib/stores/authStore";

  export let data;
  let screenMessages = data.screenMessages;
  let activeMessage = data.activeMessage[0];

  let messageVisible = activeMessage.isVisible;
  async function updateActiveMessage() {
    await pb.collection("activeMessage").update(activeMessage.id, {
      message: selectedMessage.id,
      isVisible: messageVisible
    });
  }

  let selectedMessage = { id: activeMessage.message };

  async function updateScreenMessages() {
    updateActiveMessage();
    for (let message of screenMessages) {
      await pb.collection("screenMessages").update(message.id, {
        title: message.title,
        subtext: message.subtext
      });
    }
  }
</script>

<form>
  <ul class="list-none">
    {#each screenMessages as message}
      <div class="flex">
        <div class="form-control">
          <label class="label cursor-pointer">
            <input
              type="radio"
              name="selected"
              class="radio mr-2 mt-4"
              checked={message.id == selectedMessage.id}
              on:change={() => {
                selectedMessage = message;
                messageVisible = true;
              }}
            />

            <li>
              <input
                type="text"
                placeholder="Tittel"
                bind:value={message.title}
                class="input input-lg input-bordered w-full max-w-xs"
              />
            </li>

            <li>
              <input
                type="text"
                placeholder="Beskrivelse"
                bind:value={message.subtext}
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
      on:change={() => (messageVisible = false)}
    />
    <span class="text-lg">Åpent!</span>
  </ul>

  <button type="submit" class="btn mt-4 w-full max-w-xs" on:click={updateScreenMessages}
    >Lagre</button
  >
</form>
