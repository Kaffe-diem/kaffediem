import { PUBLIC_BACKEND_URL } from "$env/static/public";
import { getSocket } from "$lib/realtime/socket";
import { writable, type Writable } from "svelte/store";
import type { Channel } from "phoenix";

type ChangeEvent<Api> = {
  action: "create" | "update" | "delete";
  record: Api | { id?: string | number } | null;
};

type CollectionPayload<Api> = {
  items?: Api[];
};

export function createCollection<Api, T extends { id: string | number }>(
  collectionName: string,
  fromApi: (data: Api) => T,
  options?: {
    queryParams?: Record<string, string>;
    onCreate?: (item: T) => void;
  }
): Writable<T[]> & { destroy: () => void } {
  return createChannelStore<T[]>(collectionName, {
    initialValue: [],
    queryParams: options?.queryParams,
    extract: (response: unknown) => {
      const items = Array.isArray((response as CollectionPayload<Api>)?.items)
        ? ((response as CollectionPayload<Api>).items ?? [])
        : [];
      return items.map(fromApi);
    },
    onChange: (rawEvent, { update }) => {
      const event = rawEvent as ChangeEvent<Api>;
      if (!event?.record) return;

      switch (event.action) {
        case "create": {
          update((items) => {
            const item = fromApi(event.record as Api);
            options?.onCreate?.(item);
            return [...items, item];
          });
          break;
        }
        case "update": {
          const item = fromApi(event.record as Api);
          update((items) => {
            const index = items.findIndex((i) => i.id === item.id);
            if (index === -1) return [...items, item];
            const next = [...items];
            next[index] = item;
            return next;
          });
          break;
        }
        case "delete": {
          const id = (event.record as { id?: string })?.id;
          if (id) {
            update((items) => items.filter((i) => i.id !== id));
          }
          break;
        }
        default:
          break;
      }
    }
  });
}

type ChannelStoreOptions<T> = {
  initialValue: T;
  queryParams?: Record<string, string>;
  extract: (response: unknown) => T;
  onChange?: (
    event: unknown,
    helpers: { set: (value: T) => void; update: (updater: (value: T) => T) => void }
  ) => void;
};

export function createChannelStore<T>(
  channelName: string,
  options: ChannelStoreOptions<T>
): Writable<T> & { destroy: () => void } {
  const { initialValue, queryParams = {}, extract, onChange } = options;
  const { subscribe, set, update } = writable<T>(initialValue);
  let channel: Channel | null = null;

  const socket = getSocket();
  if (socket) {
    channel = socket.channel(`collection:${channelName}`, { options: queryParams });

    channel
      .join()
      .receive("ok", (payload: unknown) => {
        set(extract(payload));
      })
      .receive("error", (error: unknown) => {
        console.error(`Failed to join ${channelName}:`, error);
        set(initialValue);
      });

    if (onChange) {
      channel.on("change", (event: unknown) => {
        onChange(event, { set, update });
      });
    }
  }

  return {
    subscribe,
    set,
    update,
    destroy: () => {
      if (channel) {
        channel.leave();
        channel = null;
      }
    }
  };
}

const backendUrl = (() => {
  if (!PUBLIC_BACKEND_URL) return "";
  try {
    const url = new URL(PUBLIC_BACKEND_URL);
    url.pathname = url.pathname.replace(/\/$/, "");
    return url.toString();
  } catch {
    return "";
  }
})();

function buildUrl(path: string): string {
  if (!backendUrl) return path;
  return new URL(path, backendUrl).toString();
}

export async function apiPost(collection: string, body: unknown): Promise<void> {
  const url = buildUrl(`/api/collections/${collection}/records`);
  const init: RequestInit = {
    method: "POST",
    credentials: "include"
  };

  if (body instanceof FormData) {
    init.body = body;
  } else {
    init.body = JSON.stringify(body);
    init.headers = { "Content-Type": "application/json" };
  }

  const res = await fetch(url, init);
  if (!res.ok) throw new Error(`POST ${url} failed: ${res.status}`);
}

export async function apiPatch(
  collection: string,
  id: string | number,
  body: unknown
): Promise<void> {
  const url = buildUrl(`/api/collections/${collection}/records/${id}`);
  const init: RequestInit = {
    method: "PATCH",
    credentials: "include"
  };

  if (body instanceof FormData) {
    init.body = body;
  } else {
    init.body = JSON.stringify(body);
    init.headers = { "Content-Type": "application/json" };
  }

  const res = await fetch(url, init);
  if (!res.ok) throw new Error(`PATCH ${url} failed: ${res.status}`);
}

export async function apiDelete(collection: string, id: string | number): Promise<void> {
  const url = buildUrl(`/api/collections/${collection}/records/${id}`);
  const res = await fetch(url, {
    method: "DELETE",
    credentials: "include"
  });
  if (!res.ok) throw new Error(`DELETE ${url} failed: ${res.status}`);
}

export function createCrudOperations<T extends { id: string | number }>(
  resourceName: string,
  options?: {
    toApi?: (entity: T) => unknown;
  }
) {
  const toApi = options?.toApi ?? ((entity: T) => entity);

  return {
    create: async (entity: T): Promise<void> => {
      await apiPost(resourceName, toApi(entity));
    },
    update: async (entity: T): Promise<void> => {
      await apiPatch(resourceName, entity.id, toApi(entity));
    },
    delete: async (id: string | number): Promise<void> => {
      await apiDelete(resourceName, id);
    }
  };
}
