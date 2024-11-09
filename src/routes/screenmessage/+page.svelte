<script lang="ts">
  import { pb } from "$lib/stores/authStore";

  export let data;
  let screenMessages = data.screenMessages;
  let activeMessage = data.activeMessage[0];

  let open = !activeMessage.isVisible;
  async function updateActiveMessage() {
    await pb.collection("activeMessage").update(activeMessage.id, {
      isVisible: !open
    });
  }

  let selectedMessage;

  async function updateScreenMessages() {
    updateActiveMessage();
    for (let message of screenMessages) {
      await pb.collection("screenMessages").update(message.id, {
        title: message.title,
        subtext: message.subtext,
        isVisible: message.id == selectedMessage.id
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
              value={message}
              checked={message.isVisible}
              on:change={() => {
                selectedMessage = message;
                open = false;
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
      checked={open}
      on:change={() => (open = true)}
    />
    <span class="text-lg">Åpent!</span>
  </ul>

  <button type="submit" class="btn mt-4 w-full max-w-xs" on:click={updateScreenMessages}>OK</button>
</form>
