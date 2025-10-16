import { get, writable } from "svelte/store";
import { createCollection, apiPost, apiPatch, apiDelete } from "./collection";
import {
  messageFromApi,
  messageToApi,
  statusFromApi,
  statusToApi,
  type Message,
  type Status
} from "$lib/types";

// Messages collection
export const messages = createCollection("message", messageFromApi);

// Status is singleton - only one record
const statusCollection = createCollection("status", statusFromApi);

const emptyStatus: Status = {
  id: "",
  open: false,
  showMessage: false,
  messageId: null
};

const { subscribe, set } = writable<Status>(emptyStatus);

// Subscribe to collection and grab first record
statusCollection.subscribe((records) => {
  set(records[0] ?? emptyStatus);
});

export const status = {
  subscribe
};

// CRUD for messages
export async function createMessage(msg: Message): Promise<void> {
  await apiPost("message", messageToApi(msg));
}

export async function updateMessage(msg: Message): Promise<void> {
  await apiPatch("message", msg.id, messageToApi(msg));
}

export async function deleteMessage(id: string): Promise<void> {
  await apiDelete("message", id);
}

// Update status (only one record)
export async function updateStatus(status: Status): Promise<void> {
  await apiPatch("status", status.id, statusToApi(status));
}
