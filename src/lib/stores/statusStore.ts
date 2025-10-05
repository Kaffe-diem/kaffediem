import {
  createCollectionCrud,
  createCollectionStore,
  sendCollectionRequest
} from "$stores/websocketStore";
import { Collections, Message, Status } from "$lib/types";
import { get, writable } from "svelte/store";

export const messages = createCollectionCrud(Collections.Message, {
  fromWire: Message.fromApi
});

const statusSource = createCollectionStore(
  Collections.Status,
  {
    fromWire: (data) => Status.fromApi(data, get(messages))
  }
);

const { subscribe, set } = writable(Status.baseValue);

statusSource.subscribe((records) => {
  const [first] = records;
  set(first ?? Status.baseValue);
});

export const status = {
  subscribe,
  destroy: statusSource.destroy,
  reset: () => undefined,
  update: async (status: Status) => {
    await sendCollectionRequest("PATCH", Collections.Status, status.id, status.toApi());
  }
};
