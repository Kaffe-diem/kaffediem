import { browser } from "$app/environment";
import type { Collections, RecordIdString } from "$lib/pocketbase";
import type { RecordBase } from "$lib/types";
import { getSocket } from "$lib/realtime/socket";
import { writable } from "svelte/store";
import type { Channel } from "phoenix";

type CollectionHandlers<RecordClass extends RecordBase> = {
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  fromWire(data: any): RecordClass;
};

type Subscription = {
  teardown: () => Promise<void> | void;
};

type ChangeEvent = {
  action: "create" | "update" | "delete";
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  record: any;
};

export function createCollectionStore<
  Collection extends Collections,
  RecordClass extends RecordBase
>(
  collection: Collection,
  handlers: CollectionHandlers<RecordClass>,
  options: Record<string, string> = {}
) {
  const { subscribe, set, update } = writable<RecordClass[]>([]);
  let subscription: Subscription | null = null;

  if (browser) {
    const socket = getSocket();

    if (socket) {
      const channel: Channel = socket.channel(`collection:${collection}`, {
        options
      });

      channel
        .join()
        .receive("ok", (payload) => {
          if (payload && Array.isArray(payload.items)) {
            set(payload.items.map(handlers.fromWire));
          } else {
            set([]);
          }
        })
        .receive("error", (error) => {
          console.error(`Failed to join collection:${collection}`, error);
        })
        .receive("timeout", () => {
          console.error(`Timeout joining collection:${collection}`);
        });

      const listener = (event: ChangeEvent) => {
        if (!event || !event.record) return;

        update((items) => applyChange(items, event, handlers));
      };

      channel.on("change", listener);

      subscription = {
        teardown: async () => {
          channel.off("change", listener);
          void channel.leave();
        }
      };
    }
  }

  return {
    subscribe,
    destroy: () => subscription?.teardown(),
    reset: () => undefined
  };
}

export function createCollectionCrud<
  Collection extends Collections,
  RecordClass extends RecordBase
>(
  collection: Collection,
  handlers: CollectionHandlers<RecordClass>,
  options: Record<string, string> = {}
) {
  const store = createCollectionStore(collection, handlers, options);

  return {
    ...store,
    create: async (record: RecordClass) => {
      await sendCollectionRequest("POST", collection, null, record.toPb());
    },
    update: async (record: RecordClass) => {
      await sendCollectionRequest("PATCH", collection, record.id, record.toPb());
    },
    delete: async (id: RecordIdString) => {
      await sendCollectionRequest("DELETE", collection, id, undefined);
    },
    reset: store.reset
  };
}

function applyChange<RecordClass extends RecordBase>(
  items: RecordClass[],
  event: ChangeEvent,
  handlers: CollectionHandlers<RecordClass>
) {
  const next = [...items];
  const index = next.findIndex((item) => item.id === event.record.id);

  switch (event.action) {
    case "delete":
      if (index !== -1) next.splice(index, 1);
      break;

    case "create":
    case "update":
      const mapped = handlers.fromWire(event.record);
      if (index !== -1) {
        next[index] = mapped;
      } else {
        next.push(mapped);
      }
      break;
  }

  return next;
}

export async function sendCollectionRequest(
  method: "POST" | "PATCH" | "DELETE",
  collection: string,
  id: string | null,
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  payload: any
) {
  const url = `/api/collections/${collection}/records${id ? `/${id}` : ""}`;
  const init: RequestInit = {
    method,
    credentials: "include"
  };

  if (payload instanceof FormData) {
    init.body = payload;
  } else if (payload !== undefined) {
    init.body = JSON.stringify(payload);
    init.headers = {
      "Content-Type": "application/json"
    };
  }

  const response = await fetch(url, init);

  if (!response.ok) {
    throw new Error(`Request to ${url} failed with status ${response.status}`);
  }
}
