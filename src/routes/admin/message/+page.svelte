<script lang="ts">
  import {
  messages,
  status,
  createMessage,
  updateMessage,
  deleteMessage,
  updateStatus
} from "$stores/status";
  import type { Message, Status } from "$lib/types";
  import Visible from "$assets/Visible.svelte";
  import Hidden from "$assets/Hidden.svelte";
  import { get } from "svelte/store";

  const selectedMessage = $derived(
    $messages.find((message) => message.id === $status.messageId) ?? {
      id: "",
      title: "",
      subtitle: ""
    }
  );

  const patchStatus = async (changes: Partial<Status>) => {
    const current = get(status);
    if (!current.id) return;
    await updateStatus({ ...current, ...changes });
  };

  const handleStatusChange = (message: Message) => {
    void patchStatus({ messageId: message.id });
  };

  const handleTitleChange = (event: Event, message: Message) => {
    const updated: Message = {
      ...message,
      title: (event.target as HTMLInputElement).value
    };
    void updateMessage(updated);
  };

  const handleSubtitleChange = (event: Event, message: Message) => {
    const updated: Message = {
      ...message,
      subtitle: (event.target as HTMLInputElement).value
    };
    void updateMessage(updated);
  };

  const toggleOpen = () => {
    const current = get(status);
    void patchStatus({ open: !current.open });
  };

  const toggleShowMessage = () => {
    const current = get(status);
    void patchStatus({ showMessage: !current.showMessage });
  };

  const addMessage = () => {
    const baseMessage: Message = { id: "", title: "", subtitle: "" };
    void createMessage(baseMessage);
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
            checked={message.id === selectedMessage.id}
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
                void deleteMessage(message.id);
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
