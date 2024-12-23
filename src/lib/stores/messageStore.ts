import createPbStore from "$stores/pbStore";
import pb, { Collections, type RecordIdString } from "$lib/pocketbase";
import { Message, ActiveMessage } from "$lib/types";
import { writable } from "svelte/store";

import eventsource from "eventsource";
// eslint-disable-next-line @typescript-eslint/no-explicit-any
(global as any).EventSource = eventsource;

export const messages = {
  subscribe: createPbStore(Collections.DisplayMessages, Message),
  create: async (title: string, subtext: string) => {
    await pb.collection(Collections.DisplayMessages).create({
      title,
      subtext
    });
  },
  update: async (message: Message) => {
    await pb.collection(Collections.DisplayMessages).update(message.id, {
      title: message.title,
      subtext: message.subtext
    });
  },
  delete: async (messageId: RecordIdString) => {
    await pb.collection(Collections.DisplayMessages).delete(messageId);
  }
};

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
      })
    })
  );

  (async () => {
    // Only use the first record. Assumes that PB already has this and only this record.
    const initialData = await pb.collection(Collections.ActiveMessage).getFirstListItem("", {
      expand: "message"
    });

    set(
      new ActiveMessage({
        id: initialData.id,
        message:
          initialData.expand !== undefined
            ? new Message((initialData.expand as { message: Message }).message)
            : new Message({
                id: "",
                title: "",
                subtext: ""
              }),
        visible: initialData.isVisible
      })
    );

    pb.collection(Collections.ActiveMessage).subscribe(
      "*",
      (event) => {
        set(
          new ActiveMessage({
            id: event.record.id,
            message: (event.record.expand as { message: Message }).message,
            visible: event.record.isVisible
          })
        );
      },
      {
        expand: "message"
      }
    );
  })();

  return subscribe;
}

export const activeMessage = {
  subscribe: createActiveMessageStore(),
  update: async (activeMessage: ActiveMessage) => {
    await pb.collection(Collections.ActiveMessage).update(activeMessage.id, {
      message: activeMessage.message.id,
      isVisible: activeMessage.visible
    });
  }
};
