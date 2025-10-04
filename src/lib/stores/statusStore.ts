import {
  createCollectionCrud,
  createCollectionStore,
  sendCollectionRequest
} from "$stores/websocketStore";
import { Collections } from "$lib/pocketbase";
import { Message, Status } from "$lib/types";
import { get, writable } from "svelte/store";

export const messages = createCollectionCrud(Collections.Message, {
  fromWire: Message.fromPb
});

const statusSource = createCollectionStore(
  Collections.Status,
  {
    fromWire: (data) => Status.fromPb(data, get(messages))
  },
  {
    expand: "message"
  }
);

const { subscribe, set } = writable(Status.baseValue);

statusSource.subscribe((records) => {
  if (records.length > 0) {
    set(records[0]);
  } else {
    set(Status.baseValue);
  }
});

export const status = {
  subscribe,
  destroy: statusSource.destroy,
  reset: () => undefined,
  update: async (status: Status) => {
    await sendCollectionRequest("PATCH", Collections.Status, status.id, status.toPb());
  }
};
