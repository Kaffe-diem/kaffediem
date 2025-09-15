import { createGenericPbStore } from "$stores/pbStore";
import pb, { Collections, type MessageResponse } from "$lib/pocketbase";
import { Message, Status } from "$lib/types";
import { writable } from "svelte/store";
import { browser } from "$app/environment";

import eventsource from "eventsource";
import type { UnsubscribeFunc } from "pocketbase";
// eslint-disable-next-line @typescript-eslint/no-explicit-any
(global as any).EventSource = eventsource;

export const messages = createGenericPbStore(Collections.Message, Message);

function createStatusStore() {
  const { subscribe, set, update } = writable(Status.baseValue);

  let unsubscribeStatus: UnsubscribeFunc | null = null;
  let unsubscribeMessage: UnsubscribeFunc | null = null;

  async function reset() {
    // Only use the first record. Assumes that PB already has this and only this record.
    const initialActiveMessage = await pb.collection(Collections.Status).getFirstListItem("");
    const initialMessages: MessageResponse[] = await pb
      .collection(Collections.Message)
      .getFullList();

    const initialData = Status.fromPb(initialActiveMessage, initialMessages.map(Message.fromPb));
    set(initialData);

    if (unsubscribeStatus) {
      unsubscribeStatus();
    }
    unsubscribeStatus = await pb.collection(Collections.Status).subscribe("*", async (event) => {
      update((state) => {
        return Status.fromPb(event.record, state.messages);
      });
    });

    if (unsubscribeMessage) {
      unsubscribeMessage();
    }
    unsubscribeMessage = await pb.collection(Collections.Message).subscribe("*", (event) => {
      update((state) => {
        const itemIndex = state.messages.findIndex((item) => item.id == event.record.id);
        const item = Message.fromPb(event.record);

        switch (event.action) {
          case "create":
            state.messages.push(item);
            break;
          case "update":
            if (itemIndex !== -1) state.messages[itemIndex] = item;
            break;
          case "delete":
            if (itemIndex !== -1) state.messages.splice(itemIndex, 1);
            break;
        }

        return state;
      });
    });
  }

  if (browser) {
    reset();
  }

  return {
    subscribe,
    reset
  };
}

export const status = {
  ...createStatusStore(),
  update: async (status: Status) => {
    await pb.collection(Collections.Status).update(status.id, status.toPb());
  }
};
