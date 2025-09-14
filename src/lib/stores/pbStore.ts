import pb, { Collections, type RecordIdString } from "$lib/pocketbase";
import { writable } from "svelte/store";
import { type RecordBase } from "$lib/types";
import { browser } from "$app/environment";

// ref: https://github.com/pocketbase/js-sdk?tab=readme-ov-file#nodejs-via-npm
import eventsource from "eventsource";
// eslint-disable-next-line @typescript-eslint/no-explicit-any
(global as any).EventSource = eventsource;

export function createPbStore<Collection extends Collections, RecordClass extends RecordBase>(
  collection: Collection,
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  recordClass: { fromPb(data: any): RecordClass },
  fetchOptions: { [key: string]: string } = {},
  subscribeOptions: { [key: string]: string } = fetchOptions
) {
  const { subscribe, set, update } = writable<RecordClass[]>([]);

  async function reset() {
    const initialData = await pb.collection(collection).getFullList(fetchOptions);
    set(initialData.map(recordClass.fromPb));

    // pb.collection(collection).unsubscribe();
    pb.collection(collection).subscribe(
      "*",
      (event) => {
        update((state) => {
          const itemIndex = state.findIndex((item) => item.id == event.record.id);
          const item = recordClass.fromPb(event.record);

          switch (event.action) {
            case "create":
              state.push(item);
              break;
            case "update":
              if (itemIndex !== -1) state[itemIndex] = item;
              break;
            case "delete":
              if (itemIndex !== -1) state.splice(itemIndex, 1);
              break;
          }

          return state;
        });
      },
      subscribeOptions
    );
  }

  if (browser) {
    reset();
  }

  return {
    subscribe,
    reset
  };
}

export function createGenericPbStore<
  Collection extends Collections,
  RecordClass extends RecordBase
>(
  collection: Collection,
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  recordClass: { fromPb(data: any): RecordClass },
  fetchOptions: { [key: string]: string } = {},
  subscribeOptions: { [key: string]: string } = fetchOptions
) {
  return {
    ...createPbStore(collection, recordClass, fetchOptions, subscribeOptions),
    update: async (record: RecordClass) => {
      await pb.collection(collection).update(record.id, record.toPb());
    },
    create: async (record: RecordClass) => {
      await pb.collection(collection).create(record.toPb());
    },
    delete: async (id: RecordIdString) => {
      await pb.collection(collection).delete(id);
    }
  };
}
