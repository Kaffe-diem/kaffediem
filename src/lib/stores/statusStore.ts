import { createGenericPbStore } from "$stores/pbStore";
import pb, { Collections, type MessageResponse } from "$lib/pocketbase";
import { Message, Status } from "$lib/types";
import { writable } from "svelte/store";
import { browser } from "$app/environment";

import eventsource from "eventsource";
import type { UnsubscribeFunc } from "pocketbase";
// eslint-disable-next-line @typescript-eslint/no-explicit-any
(global as any).EventSource = eventsource;

export const messages = await createGenericPbStore(Collections.Message, Message);

async function createStatusStore() {
  const { subscribe, set, update } = writable(Status.baseValue);

  async function reset() {
    // Only use the first record. Assumes that PB already has this and only this record.
    const initialActiveMessage = await pb.collection(Collections.Status).getFirstListItem("");
    const initialMessages: MessageResponse[] = await pb
      .collection(Collections.Message)
      .getFullList();

    const initialData = Status.fromPb(initialActiveMessage, initialMessages.map(Message.fromPb));
    set(initialData);
  }

  if (browser) {
    reset();

    await pb.collection(Collections.Status).subscribe("*", async (event) => {
      update((state) => {
        return Status.fromPb(event.record, state.messages);
      });
    });

    await pb.collection(Collections.Message).subscribe("*", (event) => {
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

  return {
    subscribe,
    reset
  };
}

export const status = {
  ...(await createStatusStore()),
  update: async (status: Status) => {
    await pb.collection(Collections.Status).update(status.id, status.toPb());
  }
};
