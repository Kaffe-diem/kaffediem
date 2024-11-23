import createPbStore from "$stores/pbStore";
import pb from "$lib/pocketbase";
import { Message, ActiveMessage } from "$lib/types";

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
    message: mapToMessage(data.expand.message),
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
  update: async (id: string, title: string, subtext: string) => {
    await pb.collection("displayMessages").update(id, { title, subtext });
  },
  delete: async (id: string) => {
    await pb.collection("displayMessages").delete(id);
  }
};

export const activeMessages = {
  subscribe: createPbStore<ActiveMessage>("activeMessage", mapToActiveMessage, {
    expand: "message"
  }),
  update: async (message: ActiveMessage) => {
    await pb.collection("activeMessage").update(message.id, {
      message: message.message,
      isVisible: message.visible
    });
  }
};
