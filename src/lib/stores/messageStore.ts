import { createGenericPbStore } from "$stores/pbStore";
import pb, { Collections } from "$lib/pocketbase";
import { Message, ActiveMessage, type ExpandedActiveMessageRecord } from "$lib/types";
import { writable } from "svelte/store";

import eventsource from "eventsource";
// eslint-disable-next-line @typescript-eslint/no-explicit-any
(global as any).EventSource = eventsource;

export const messages = createGenericPbStore(Collections.DisplayMessages, Message);

function createActiveMessageStore() {
  // Initialize with dummy non-visible message
  const { subscribe, set } = writable<ActiveMessage>(
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

  const baseOptions = {
    expand: "message"
  };

  (async () => {
    // Only use the first record. Assumes that PB already has this and only this record.
    const initialData: ExpandedActiveMessageRecord = await pb
      .collection(Collections.ActiveMessage)
      .getFirstListItem("", baseOptions);

    set(ActiveMessage.fromPb(initialData));

    pb.collection(Collections.ActiveMessage).subscribe(
      "*",
      (event: { record: ExpandedActiveMessageRecord }) => {
        set(ActiveMessage.fromPb(event.record));
      },
      baseOptions
    );
  })();

  return subscribe;
}

export const activeMessage = {
  subscribe: createActiveMessageStore(),
  update: async (activeMessage: ActiveMessage) => {
    await pb.collection(Collections.ActiveMessage).update(activeMessage.id, activeMessage.toPb());
  }
};
