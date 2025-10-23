import { writable } from "svelte/store";
import { getSocket } from "$lib/realtime/socket";
import { apiPost, apiPatch, apiDelete } from "./collection";
import {
  messageFromApi,
  messageToApi,
  statusFromApi,
  statusToApi,
  type Message,
  type Status
} from "$lib/types";

// Writable stores
export const messages = writable<Message[]>([]);

const emptyStatus: Status = {
  id: "",
  open: false,
  showMessage: false,
  messageId: null
};

const statusStore = writable<Status>(emptyStatus);

// Subscribe to semantic status channel
let channel: any | null = null;
const socket = getSocket();

if (socket) {
  channel = socket.channel("collection:status", {});

  channel
    .join()
    .receive("ok", (payload: any) => {
      parseStatusData(payload?.items);
    })
    .receive("error", (error: unknown) => {
      console.error("Failed to join status channel:", error);
      messages.set([]);
      statusStore.set(emptyStatus);
    });

  channel.on("change", (event: any) => {
    // Status changed - reload everything
    if (event?.action === "reload") {
      // Backend will send full status on next join, or we can fetch
      // For now, the individual collection broadcasts still work
    }
  });
}

// Parse status response
function parseStatusData(data: any) {
  if (!data) return;

  // Parse messages
  const parsedMessages = (data.messages || []).map((msg: any) => messageFromApi(msg));
  messages.set(parsedMessages);

  // Parse status (first record)
  const parsedStatuses = (data.statuses || []).map((s: any) => statusFromApi(s));
  statusStore.set(parsedStatuses[0] ?? emptyStatus);
}

// Export status as read-only store
export const status = {
  subscribe: statusStore.subscribe
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
export async function updateStatus(statusToUpdate: Status): Promise<void> {
  await apiPatch("status", statusToUpdate.id, statusToApi(statusToUpdate));
}

// Cleanup on module unload
export function destroyStatusChannel() {
  if (channel) {
    channel.leave();
    channel = null;
  }
}
