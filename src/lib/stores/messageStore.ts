import createPbStore from "$stores/pbStore";
import pb, {
  Collections,
  type ActiveMessageRecord,
  type ActiveMessageResponse,
  type DisplayMessagesResponse,
  type RecordIdString
} from "$lib/pocketbase";
import { writable } from "svelte/store";

import eventsource from "eventsource";
// eslint-disable-next-line @typescript-eslint/no-explicit-any
(global as any).EventSource = eventsource;

export const messages = {
  subscribe: createPbStore(Collections.DisplayMessages),
  create: async (title: string, subtext: string) => {
    await pb.collection(Collections.DisplayMessages).create({
      title,
      subtext
    });
  },
  update: async (message: DisplayMessagesResponse) => {
    await pb.collection(Collections.DisplayMessages).update(message.id, {
      title: message.title,
      subtext: message.subtext
    });
  },
  delete: async (id: RecordIdString) => {
    await pb.collection(Collections.DisplayMessages).delete(id);
  }
};

function createActiveMessageStore() {
  // Initialize with dummy non-visible message
  const { subscribe, set } = writable<ActiveMessageRecord>();

  (async () => {
    const initialData = await pb.collection(Collections.ActiveMessage).getFullList({
      expand: "message"
    });

    set(initialData[0]);

    pb.collection(Collections.ActiveMessage).subscribe(
      "*",
      (event: { record: ActiveMessageRecord }) => {
        set(event.record);
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
  update: async (message: ActiveMessageResponse) => {
    await pb.collection(Collections.ActiveMessage).update(message.id, {
      message: message.message.id,
      isVisible: message.isVisible
    });
  }
};
