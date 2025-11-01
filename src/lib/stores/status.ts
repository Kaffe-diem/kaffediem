import { derived } from "svelte/store";
import { apiPatch, createChannelStore, createCrudOperations } from "./collection";
import type { Message, Status } from "$lib/types";

const emptyStatus: Status = {
  id: "",
  open: false,
  show_message: false,
  message: null
};

type StatusPayload = {
  messages: Message[];
  status: Status;
};

const statusChannel = createChannelStore<StatusPayload>("status", {
  initialValue: { messages: [], status: emptyStatus },
  extract: (response: unknown) => {
    const items = (response as { items?: { messages?: unknown; statuses?: unknown } })?.items;
    if (!items) return { messages: [], status: emptyStatus };

    const messages = Array.isArray(items.messages) ? (items.messages as Message[]) : [];
    const statuses = Array.isArray(items.statuses) ? (items.statuses as Status[]) : [];

    return {
      messages,
      status: statuses[0] ?? emptyStatus
    };
  }
});

export const messages = derived(statusChannel, ($statusChannel) => $statusChannel.messages);
export const status = derived(statusChannel, ($statusChannel) => $statusChannel.status);

// CRUD for messages
export const {
  create: createMessage,
  update: updateMessage,
  delete: deleteMessage
} = createCrudOperations<Message>("message", {
  toApi: (msg) => ({ title: msg.title, subtitle: msg.subtitle ?? null })
});

// Update status (only one record)
export async function updateStatus(statusToUpdate: Status): Promise<void> {
  await apiPatch("status", statusToUpdate.id, {
    open: statusToUpdate.open,
    show_message: statusToUpdate.show_message,
    message: statusToUpdate.message
  });
}

export function destroyStatusChannel() {
  statusChannel.destroy();
}
