import { apiPatch, createCollection, createCrudOperations } from "./collection";
import type { Message, Status } from "$lib/types";

const emptyStatus: Status = {
  id: 0,
  open: false,
  show_message: false,
  message_id: null
};

export const messages = createCollection<Message, Message>("message", (data) => data);

const statusCollection = createCollection<Status, Status>("status", (data) => data);

// status is singleton, so we just get the first one
import { derived } from "svelte/store";
export const status = derived(statusCollection, ($statuses) => $statuses[0] ?? emptyStatus);

export const {
  create: createMessage,
  update: updateMessage,
  delete: deleteMessage
} = createCrudOperations<Message>("message", {
  toApi: (msg) => ({ title: msg.title, subtitle: msg.subtitle ?? null })
});

export async function updateStatus(statusToUpdate: Status): Promise<void> {
  await apiPatch("status", statusToUpdate.id, {
    open: statusToUpdate.open,
    show_message: statusToUpdate.show_message,
    message_id: statusToUpdate.message_id
  });
}

export function destroyStatusChannel() {
  statusCollection.destroy();
  messages.destroy();
}
