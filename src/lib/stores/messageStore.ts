import createPbStore from "$stores/pbStore";
import pb from "$lib/pocketbase";
import { Message, ActiveMessage } from "$lib/types";
import { writable } from "svelte/store";

import eventsource from "eventsource";
// eslint-disable-next-line @typescript-eslint/no-explicit-any
(global as any).EventSource = eventsource;

const mapToMessage = (data: { id: string; title: string; subtext: string }): Message =>
  new Message({
    id: data.id,
    title: data.title,
    subtext: data.subtext
  });

// FIXME: again, pocketbase typing
// eslint-disable-next-line @typescript-eslint/no-explicit-any
const mapToActiveMessage = (data: { id: string; expand: any; isVisible: boolean }): ActiveMessage =>
  new ActiveMessage({
    id: data.id,
    message:
      data.expand !== undefined
        ? mapToMessage(data.expand.message)
        : new Message({
            id: "",
            title: "",
            subtext: ""
          }),
    visible: data.isVisible
  });

export const messages = {
  subscribe: createPbStore<Message>("displayMessages", mapToMessage),
  create: async (title: string, subtext: string) => {
    await pb.collection("displayMessages").create({
      title,
      subtext
    });
  },
  update: async (message: Message) => {
    await pb.collection("displayMessages").update(message.id, {
      title: message.title,
      subtext: message.subtext
    });
  },
  delete: async (id: string) => {
    await pb.collection("displayMessages").delete(id);
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
    const initialData = await pb.collection("activeMessage").getFullList({
      expand: "message"
    });

    // Only use the first record. Assumes that PB already has this record.
    // @ts-expect-error Typing again
    set(mapToActiveMessage(initialData[0]));

    pb.collection("activeMessage").subscribe(
      "*",
      (event) => {
        // @ts-expect-error Typing again
        set(mapToActiveMessage(event.record));
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
  update: async (message: ActiveMessage) => {
    await pb.collection("activeMessage").update(message.id, {
      message: message.message.id,
      isVisible: message.visible
    });
  }
};
