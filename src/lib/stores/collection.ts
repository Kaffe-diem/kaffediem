// Simplified collection store

import { browser } from "$app/environment";
import { PUBLIC_BACKEND_URL } from "$env/static/public";
import { getSocket } from "$lib/realtime/socket";
import { writable, type Writable } from "svelte/store";
import type { Channel } from "phoenix";

type ChangeEvent = {
  action: "create" | "update" | "delete";
  record: unknown;
};

// Create generic stores
export function createCollection<T extends { id: string }>(
  collectionName: string,
  fromApi: (data: any) => T,
  options?: {
    queryParams?: Record<string, string>;
    onCreate?: (item: T) => void;
  }
): Writable<T[]> & { destroy: () => void } {
  const { subscribe, set, update } = writable<T[]>([]);
  let channel: Channel | null = null;

  if (browser) {
    const socket = getSocket();
    if (socket) {
      channel = socket.channel(`collection:${collectionName}`, {
        options: options?.queryParams ?? {}
      });

      channel
        .join()
        .receive("ok", (payload) => {
          const items = Array.isArray(payload?.items) ? payload.items : [];
          set(items.map(fromApi));
        })
        .receive("error", (error) => {
          console.error(`Failed to join ${collectionName}:`, error);
          set([]);
        });

      channel.on("change", (event: ChangeEvent) => {
        if (!event?.record) return;

        if (event.action === "create") {
          const item = fromApi(event.record);
          options?.onCreate?.(item);
          update((items) => [...items, item]);
        } else if (event.action === "update") {
          const item = fromApi(event.record);
          update((items) => {
            const index = items.findIndex((i) => i.id === item.id);
            if (index === -1) return [...items, item];
            const next = [...items];
            next[index] = item;
            return next;
          });
        } else if (event.action === "delete") {
          const id = (event.record as { id?: string })?.id;
          if (id) {
            update((items) => items.filter((i) => i.id !== id));
          }
        }
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

// API methods
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

export async function apiPatch(collection: string, id: string, body: unknown): Promise<void> {
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

export async function apiDelete(collection: string, id: string): Promise<void> {
  const url = buildUrl(`/api/collections/${collection}/records/${id}`);
  const res = await fetch(url, {
    method: "DELETE",
    credentials: "include"
  });
  if (!res.ok) throw new Error(`DELETE ${url} failed: ${res.status}`);
}
