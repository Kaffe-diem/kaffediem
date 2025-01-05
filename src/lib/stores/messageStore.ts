import { createGenericPbStore } from "$stores/pbStore";
import pb, {
  Collections,
  type ActiveMessageResponse,
  type DisplayMessagesResponse
} from "$lib/pocketbase";
import { Message, ActiveMessage } from "$lib/types";
import { writable } from "svelte/store";

import eventsource from "eventsource";
// eslint-disable-next-line @typescript-eslint/no-explicit-any
(global as any).EventSource = eventsource;

export const messages = createGenericPbStore(Collections.DisplayMessages, Message);

function createActiveMessageStore() {
  // Initialize with dummy non-visible message
  const { subscribe, set, update } = writable<ActiveMessage>(
    new ActiveMessage({
      id: "",
      visible: false,
      message: new Message({
        id: "",
        title: "",
        subtext: ""
      } as Message)
    } as ActiveMessage)
  );

  (async () => {
    // Only use the first record. Assumes that PB already has this and only this record.
    const initialActiveMessage = await pb
      .collection(Collections.ActiveMessage)
      .getFirstListItem("");

    const initialMessages: DisplayMessagesResponse[] = await pb
      .collection(Collections.DisplayMessages)
      .getFullList();
    const initialMessage: DisplayMessagesResponse =
      initialMessages.filter((message) => message.id == initialActiveMessage.message)[0] ||
      ({ id: "", title: "", subtext: "" } as DisplayMessagesResponse);

    const initialData = ActiveMessage.fromPb(initialActiveMessage, Message.fromPb(initialMessage));
    set(initialData);

    pb.collection(Collections.ActiveMessage).subscribe("*", (event) => {
      update((state) => {
        return ActiveMessage.fromPb(event.record, state.message);
      });
    });

    pb.collection(Collections.DisplayMessages).subscribe("*", (event) => {
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
    await pb.collection(Collections.ActiveMessage).update(activeMessage.id, activeMessage.toPb());
  }
};
