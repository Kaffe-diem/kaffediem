<script lang="ts">
  import { messages, status } from "$stores/statusStore";
  import { Message, Status } from "$lib/types";

  const handleStatusChange = (message: Message) => {
    status.update(new Status($status.id, message, $status.messages, true));
  };

  const handleTitleChange = (event: Event, message: Message) => {
    messages.update(
      new Message(message.id, (event.target as HTMLInputElement).value, message.subtitle)
    );
  };

  const handleSubtitleChange = (event: Event, message: Message) => {
    messages.update(
      new Message(message.id, message.title, (event.target as HTMLInputElement).value)
    );
  };

  const handleVisibilityChange = () => {
    status.update(new Status($status.id, $status.message, $status.messages, false));
  };

  const addMessage = () => {
    const lastMessage = $messages.at(-1);
    if (lastMessage?.title || lastMessage?.subtitle) {
      messages.create(Message.baseValue);
    } else {
      window.alert("Fyll ut den siste meldingen før du legger til en ny.");
    }
  };
</script>

<form>
  <ul class="list-none">
    {#each $messages as message (message.id)}
      <li class="my-8">
        <label class="form-control grid grid-cols-[auto_1fr_1fr_auto] place-items-center gap-4">
          <input
            type="radio"
            class="radio radio-xl"
            name="selected"
            checked={message.id == $status.message.id}
            value={message}
            onchange={() => handleStatusChange(message)}
          />
          <input
            type="text"
            class="input input-xl w-full"
            value={message.title}
            placeholder="Tittel"
            oninput={(event) => handleTitleChange(event, message)}
          />
          <input
            type="text"
            class="input input-xl w-full"
            value={message.subtitle}
            placeholder="Beskrivelse"
            oninput={(event) => handleSubtitleChange(event, message)}
          />
          <button
            class="btn btn-secondary btn-xl"
            onclick={() => {
              if (window.confirm(`Er du sikker på at du vil slette "${message.title}"?`)) {
                messages.delete(message.id);
              }
            }}>-</button
          >
        </label>
      </li>
    {/each}
    <li class="my-4">
      <label class="flex items-center">
        <input
          type="radio"
          class="radio radio-xl mr-4"
          name="selected"
          checked={!$status.online}
          onchange={handleVisibilityChange}
        />
        <span class="ml-3 text-xl">Åpent!</span>
      </label>
    </li>
    <button class="btn btn-xl w-full" onclick={addMessage}
      >Legg til melding</button
    >
  </ul>
</form>
