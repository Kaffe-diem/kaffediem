import createPbStore from "$stores/pbStore";
import pb, {
  Collections,
  type ActiveMessageResponse,
  type DisplayMessagesResponse,
  type RecordIdString
} from "$lib/pocketbase";

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

export const activeMessage = {
  subscribe: createPbStore(Collections.ActiveMessage, {
    expand: "message"
  }),
  update: async (current: ActiveMessageResponse) => {
    await pb.collection(Collections.ActiveMessage).update(current.id, {
      message: current?.expand.message.id,
      isVisible: current.isVisible
    });
  }
};
