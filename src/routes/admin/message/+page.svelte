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
  import { debounce } from "$lib/utils";
  import { fade } from "svelte/transition";

  let saveState = $state<"saving" | "saved">("saved");

  const selectedMessage = $derived(
    $messages.find((message) => message.id === $status.messageId) ?? {
      id: "",
      title: "",
      subtitle: null
    }
  );

  const debouncedSave = debounce(
    async (message: Message, field: "title" | "subtitle", value: string) => {
      await updateMessage({ ...message, [field]: value });
      saveState = "saved";
    }
  );

  const handleUpdate = (message: Message, field: "title" | "subtitle", value: string) => {
    saveState = "saving";
    debouncedSave(message, field, value);
  };

  const patchStatus = async (changes: Partial<Status>) => {
    const current = get(status);
    if (!current.id) return;
    await updateStatus({ ...current, ...changes });
  };

  const handleStatusChange = (message: Message) => {
    void patchStatus({ messageId: message.id });
  };

  const handleTitleChange = (event: Event, message: Message) => {
    handleUpdate(message, "title", (event.target as HTMLInputElement).value);
  };

  const handleSubtitleChange = (event: Event, message: Message) => {
    handleUpdate(message, "subtitle", (event.target as HTMLInputElement).value);
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
    const baseMessage: Message = { id: "", title: "", subtitle: null };
    void createMessage(baseMessage);
  };

  let lastMessage = $derived($messages.at(-1));
  let disableAdd = $derived(!(lastMessage?.title || lastMessage?.subtitle));
</script>

<div class="fixed top-4 right-4 z-50">
  <div class="flex items-center gap-3">
    <span class="text-base-content/70 relative inline-block h-6 w-16 text-right">
      {#if saveState === "saving"}
        <span class="absolute right-0" in:fade={{ duration: 50 }} out:fade={{ duration: 50 }}
          >lagrer...</span
        >
      {:else}
        <span class="absolute right-0" in:fade={{ duration: 50 }} out:fade={{ duration: 50 }}
          >lagret!</span
        >
      {/if}
    </span>
    <span class="relative flex h-3 w-3">
      {#if saveState === "saving"}
        <span
          class="absolute inline-flex h-full w-full animate-ping rounded-full bg-orange-500 opacity-75"
        ></span>
        <span class="relative inline-flex h-3 w-3 rounded-full bg-orange-500"></span>
      {:else}
        <span class="relative inline-flex h-3 w-3 rounded-full bg-green-500"></span>
      {/if}
    </span>
  </div>
</div>

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
            value={message.subtitle ?? ""}
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
