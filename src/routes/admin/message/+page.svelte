<script lang="ts">
  import { messages, status } from "$stores/statusStore";
  import { Message, Status } from "$lib/types";
  import Visible from "$assets/Visible.svelte";
  import Hidden from "$assets/Hidden.svelte";

  const handleStatusChange = (message: Message) => {
    status.update(
      new Status($status.id, message, $status.messages, $status.open, $status.showMessage)
    );
  };

  const handleTitleChange = (event: Event, message: Message) => {
    messages.update(
      new Message(message.id, (event.target as HTMLInputElement).value, message.subtitle)
    );
    handleStatusChange(message);
  };

  const handleSubtitleChange = (event: Event, message: Message) => {
    messages.update(
      new Message(message.id, message.title, (event.target as HTMLInputElement).value)
    );
    handleStatusChange(message);
  };

  const toggleOpen = () => {
    status.update(
      new Status($status.id, $status.message, $status.messages, !$status.open, $status.open)
    );
  };

  const toggleShowMessage = () => {
    status.update(
      new Status($status.id, $status.message, $status.messages, $status.open, !$status.showMessage)
    );
  };

  const addMessage = () => {
    messages.create(Message.baseValue);
  };

  let lastMessage = $derived($messages.at(-1));
  let disableAdd = $derived(!(lastMessage?.title || lastMessage?.subtitle));
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
            type="button"
            class="btn btn-secondary btn-xl w-16"
            onclick={() => {
              if (window.confirm(`Er du sikker på at du vil slette "${message.title}"?`)) {
                messages.delete(message.id);
              }
            }}>-</button
          >
        </label>
      </li>
    {/each}
    <div class="grid grid-cols-[auto_1fr_auto]">
      <button
        type="button"
        class="btn btn-xl mr-4 {$status.open ? '' : 'invisible'}"
        onclick={toggleShowMessage}
        >{#if $status.showMessage}<Visible />{:else}<Hidden />{/if}</button
      >
      <button type="button" class="btn btn-xl w-full" onclick={toggleOpen}
        >{$status.open ? "Åpent" : "Stengt"}</button
      >
      <button
        type="button"
        class="btn btn-xl btn-primary ml-4 w-16"
        onclick={addMessage}
        disabled={disableAdd}>+</button
      >
    </div>
  </ul>
</form>
