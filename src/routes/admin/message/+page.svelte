<script lang="ts">
  import { messages, activeMessage } from "$stores/messageStore";
  import { Message, ActiveMessage } from "$lib/types";

  const handleActiveMessageChange = (message: Message) => {
    activeMessage.update({
      ...$activeMessage,
      visible: true,
      message
    } as ActiveMessage);
  };

  const handleMessageTextChange = (event: Event, message: Message, field: "title" | "subtitle") => {
    messages.update(
      new Message({
        ...message,
        [field]: (event.target as HTMLInputElement).value
      } as Message)
    );
  };

  const handleVisibilityChange = () => {
    activeMessage.update({
      ...$activeMessage,
      visible: false
    } as ActiveMessage);
  };
</script>

<form>
  <ul class="list-none">
    {#each $messages as message}
      <li class="my-4">
        <label class="form-control grid grid-cols-[auto_1fr_1fr_auto] place-items-center gap-4">
          <input
            type="radio"
            class="radio"
            name="selected"
            checked={message.id == $activeMessage.message.id}
            value={message}
            onchange={() => handleActiveMessageChange(message)}
          />
          <input
            type="text"
            class="input input-lg input-bordered w-full"
            value={message.title}
            placeholder="Tittel"
            oninput={(event) => handleMessageTextChange(event, message, "title")}
          />
          <input
            type="text"
            class="input input-lg input-bordered w-full"
            value={message.subtitle}
            placeholder="Beskrivelse"
            oninput={(event) => handleMessageTextChange(event, message, "subtitle")}
          />
          <button
            class="btn btn-secondary btn-lg"
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
          class="radio mr-4"
          name="selected"
          checked={!$activeMessage.visible}
          onchange={handleVisibilityChange}
        />
        <span>Åpent!</span>
      </label>
    </li>
    <button
      class="btn btn-lg"
      onclick={() => messages.create(new Message({ title: "", subtitle: "" } as Message))}
      >Legg til melding</button
    >
  </ul>
</form>
