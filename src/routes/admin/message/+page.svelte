<script lang="ts">
  import { messages, activeMessage } from "$stores/messageStore";
  import { Message, ActiveMessage } from "$lib/types";
</script>

<form>
  <ul class="list-none">
    {#each $messages as message}
      <li class="my-4">
        <label class="form-control grid grid-cols-[auto_1fr_1fr] place-items-center gap-4">
          <input
            type="radio"
            class="radio"
            name="selected"
            checked={message.id == $activeMessage.message.id}
            value={message}
            onchange={() =>
              activeMessage.update(
                new ActiveMessage({
                  ...$activeMessage,
                  visible: true,
                  message
                })
              )}
          />
          <input
            type="text"
            class="input input-lg input-bordered w-full"
            value={message.title}
            placeholder="Tittel"
            onchange={(e) =>
              messages.update(
                new Message({
                  ...message,
                  title: e.target.value
                })
              )}
          />
          <input
            type="text"
            class="input input-lg input-bordered w-full"
            value={message.subtext}
            placeholder="Beskrivelse"
            onchange={(e) =>
              messages.update(
                new Message({
                  ...message,
                  subtext: e.target.value
                })
              )}
          />
        </label>
      </li>
    {/each}
    <li class="my-4">
      <label class="flex items-center">
        <input
          type="radio"
          class="radio mr-4"
          name="selected"
          checked={!$activeMessage.visible}
          onchange={() =>
            activeMessage.update(
              new ActiveMessage({
                ...$activeMessage,
                visible: false
              })
            )}
        />
        <span>Åpent!</span>
      </label>
    </li>
  </ul>
</form>
