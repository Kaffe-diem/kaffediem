import { createGenericPbStore } from "$stores/pbStore";
import pb, { Collections, type MessageResponse } from "$lib/pocketbase";
import { Message, ActiveMessage } from "$lib/types";
import { writable } from "svelte/store";

import eventsource from "eventsource";
// eslint-disable-next-line @typescript-eslint/no-explicit-any
(global as any).EventSource = eventsource;

export const messages = createGenericPbStore(Collections.Message, Message);

function createActiveMessageStore() {
  // Initialize with dummy non-visible message
  const { subscribe, set, update } = writable<ActiveMessage>(ActiveMessage.baseValue);

  (async () => {
    // Only use the first record. Assumes that PB already has this and only this record.
    const initialActiveMessage = await pb.collection(Collections.Status).getFirstListItem("");
    const initialMessages: MessageResponse[] = await pb
      .collection(Collections.Message)
      .getFullList();

    const initialData = ActiveMessage.fromPb(
      initialActiveMessage,
      initialMessages.map(Message.fromPb)
    );
    set(initialData);

    pb.collection(Collections.Status).subscribe("*", async (event) => {
      update((state) => {
        return ActiveMessage.fromPb(event.record, state.messages);
      });
    });

    pb.collection(Collections.Message).subscribe("*", (event) => {
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
  })();

  return subscribe;
}

export const activeMessage = {
  subscribe: createActiveMessageStore(),
  update: async (activeMessage: ActiveMessage) => {
    await pb.collection(Collections.Status).update(activeMessage.id, activeMessage.toPb());
  }
};
