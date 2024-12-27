import createPbStore from "$stores/pbStore";
import pb, { Collections, type DisplayMessagesResponse } from "$lib/pocketbase";
import {
  type ActiveMessage,
  type ExpandedActiveMessageRecord,
  makeMessage,
  makeActiveMessage
} from "$lib/types";
import { writable } from "svelte/store";
import type { BaseModel } from "pocketbase";

import eventsource from "eventsource";
// eslint-disable-next-line @typescript-eslint/no-explicit-any
(global as any).EventSource = eventsource;

export const messages = createPbStore(Collections.DisplayMessages, (data: BaseModel) =>
  makeMessage({
    id: data.id,
    title: (data as DisplayMessagesResponse).title || "",
    subtext: (data as DisplayMessagesResponse).subtext || ""
  })
);

function createActiveMessageStore() {
  // Initialize with dummy non-visible message
  const { subscribe, set } = writable<ActiveMessage>(
    makeActiveMessage({
      id: "",
      visible: false,
      message: makeMessage({
        id: "",
        title: "",
        subtext: ""
      })
    })
  );

  const baseOptions = {
    expand: "message"
  };

  (async () => {
    // Only use the first record. Assumes that PB already has this and only this record.
    const initialData: ExpandedActiveMessageRecord = await pb
      .collection(Collections.ActiveMessage)
      .getFirstListItem("", baseOptions);

    set(
      makeActiveMessage({
        id: initialData.id,
        message: makeMessage(initialData.expand.message),
        visible: initialData.isVisible
      })
    );

    pb.collection(Collections.ActiveMessage).subscribe(
      "*",
      (event: { record: ExpandedActiveMessageRecord }) => {
        set(
          makeActiveMessage({
            id: event.record.id,
            message: makeMessage(event.record.expand.message),
            visible: event.record.isVisible
          })
        );
      },
      baseOptions
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
