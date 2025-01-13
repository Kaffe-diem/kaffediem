<script lang="ts">
  import { messages, status } from "$stores/statusStore";
  import { Message, Status } from "$lib/types";

  const handleStatusChange = (message: Message) => {
    status.update(
      new Status({
        ...$status,
        online: true,
        message
      } as Status)
    );
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
    status.update(
      new Status({
        ...$status,
        online: false
      } as Status)
    );
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
            checked={message.id == $status.message.id}
            value={message}
            onchange={() => handleStatusChange(message)}
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
          checked={!$status.online}
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
