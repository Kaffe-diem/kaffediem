import { browser } from "$app/environment";
import { PUBLIC_BACKEND_URL } from "$env/static/public";
import type { RecordBase, Collections, RecordIdString } from "$lib/types";
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

type CollectionChange<RecordClass extends RecordBase> = {
  event: ChangeEvent;
  record: RecordClass;
};

type CollectionStoreConfig<RecordClass extends RecordBase> = {
  options?: Record<string, string>;
  onChange?: (change: CollectionChange<RecordClass>) => void;
};

export function createCollectionStore<
  Collection extends Collections,
  RecordClass extends RecordBase
>(
  collection: Collection,
  handlers: CollectionHandlers<RecordClass>,
  config: CollectionStoreConfig<RecordClass> = {}
) {
  const { subscribe, set, update } = writable<RecordClass[]>([]);
  let subscription: Subscription | null = null;

  const options = config.options ?? {};
  const onChange = config.onChange;

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

        const mapped = event.action === "delete" ? null : handlers.fromWire(event.record);

        if (mapped) {
          onChange?.({
            event,
            record: mapped
          });
        }

        update((items) => applyChange(items, event, handlers, mapped ?? undefined));
      };

      const changeRef = channel.on("change", listener);

      subscription = {
        teardown: async () => {
          channel.off("change", changeRef);
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
  config: CollectionStoreConfig<RecordClass> = {}
) {
  const store = createCollectionStore(collection, handlers, config);

  return {
    ...store,
    create: async (record: RecordClass) => {
      await sendCollectionRequest("POST", collection, null, record.toApi());
    },
    update: async (record: RecordClass) => {
      await sendCollectionRequest("PATCH", collection, record.id, record.toApi());
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
  handlers: CollectionHandlers<RecordClass>,
  mappedRecord?: RecordClass
) {
  const next = [...items];
  const recordId = event.record?.id ?? mappedRecord?.id;
  const index = recordId ? next.findIndex((item) => item.id === recordId) : -1;

  switch (event.action) {
    case "delete":
      if (index !== -1) next.splice(index, 1);
      break;

    case "create":
    case "update":
      const mapped = mappedRecord ?? handlers.fromWire(event.record);
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
  const url = buildBackendUrl(`/api/collections/${collection}/records${id ? `/${id}` : ""}`);
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

const backendHttpBase = sanitizeBackendUrl(PUBLIC_BACKEND_URL);

function buildBackendUrl(path: string) {
  if (!backendHttpBase) {
    return path;
  }

  return new URL(path, backendHttpBase).toString();
}

function sanitizeBackendUrl(url: string | undefined) {
  if (!url || url.length === 0) return "";

  try {
    const parsed = new URL(url);
    parsed.pathname = parsed.pathname.replace(/\/$/, "");
    return parsed.toString();
  } catch (error) {
    console.warn("Invalid PUBLIC_BACKEND_URL", error);
    return "";
  }
}
