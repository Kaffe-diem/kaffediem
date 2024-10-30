<script lang="ts">
  import { pb } from "$lib/stores/authStore";

  export let data: { screenMessages };
  data = data.screenMessages;

  let selectedMessage;

  async function updateScreenMessages() {
    for (let message of data) {
      await pb.collection("screen_message").update(message.id, {
        title: message.title,
        subtext: message.subtext,
        isVisible: message.id == selectedMessage.id
      });
    }
  }
</script>

<form>
  <ul class="list-none">
    {#each data as message}
      <div class="flex">
        <div class="form-control">
          <label class="label cursor-pointer">
            <input
              type="radio"
              name="selected"
              class="radio mr-2 mt-4"
              value={message}
              checked={message.isVisible}
              on:change={() => (selectedMessage = message)}
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
  </ul>

  <button type="submit" class="btn mt-4 w-full max-w-xs" on:click={updateScreenMessages}>OK</button>
</form>
