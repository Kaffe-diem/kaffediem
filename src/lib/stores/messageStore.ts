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
  const { subscribe, set, update } = writable<ActiveMessage>(
    new ActiveMessage({
      id: "",
      visible: false,
      message: new Message({
        id: "",
        title: "",
        subtitle: ""
      } as Message)
    } as ActiveMessage)
  );

  (async () => {
    // Only use the first record. Assumes that PB already has this and only this record.
    const initialActiveMessage = await pb.collection(Collections.Status).getFirstListItem("");
    const initialMessages: MessageResponse[] = await pb
      .collection(Collections.Message)
      .getFullList();

    const initialMessage: MessageResponse =
      initialMessages.filter((message) => message.id == initialActiveMessage.message)[0] ||
      ({ id: "", title: "", subtitle: "" } as MessageResponse);

    const initialData = ActiveMessage.fromPb(initialActiveMessage, Message.fromPb(initialMessage));
    set(initialData);

    pb.collection(Collections.Status).subscribe("*", async (event) => {
      const message = await pb.collection(Collections.Message).getOne(event.record.message);
      update(() => {
        return ActiveMessage.fromPb(event.record, Message.fromPb(message));
      });
    });

    pb.collection(Collections.Message).subscribe("*", (event) => {
      update((state) => {
        if (event.record.id == state.message.id) {
          state.message = Message.fromPb(event.record);
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
