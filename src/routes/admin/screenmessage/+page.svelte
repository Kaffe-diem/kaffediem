<script lang="ts">
  import { pb } from "$lib/stores/authStore";

  export let data;
  let screenMessages = data.screenMessages;
  let activeMessage = data.activeMessage[0];

  let messageVisible = activeMessage.isVisible;
  async function updateActiveMessage() {
    await pb.collection("activeMessage").update(activeMessage.id, {
      message: selectedScreenMessage.id,
      isVisible: messageVisible
    });
  }

  let selectedScreenMessage = { id: activeMessage.message };

  async function updateScreenMessages() {
    updateActiveMessage();
    for (let screnMessage of screenMessages) {
      await pb.collection("screenMessages").update(screnMessage.id, {
        title: screnMessage.title,
        subtext: screnMessage.subtext
      });
    }
  }
</script>

<form>
  <ul class="list-none">
    {#each screenMessages as screenMessage}
      <div class="flex">
        <div class="form-control">
          <label class="label cursor-pointer">
            <input
              type="radio"
              name="selected"
              class="radio mr-2 mt-4"
              checked={screenMessage.id == selectedScreenMessage.id}
              on:change={() => {
                selectedScreenMessage = screenMessage;
                messageVisible = true;
              }}
            />

            <li>
              <input
                type="text"
                placeholder="Tittel"
                bind:value={screenMessage.title}
                class="input input-lg input-bordered w-full max-w-xs"
              />
            </li>

            <li>
              <input
                type="text"
                placeholder="Beskrivelse"
                bind:value={screenMessage.subtext}
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
