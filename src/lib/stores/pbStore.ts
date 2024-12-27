import pb, { Collections } from "$lib/pocketbase";
import { writable } from "svelte/store";
import type { BaseSystemFields } from "$lib/pocketbase";
import type { RecordModel } from "pocketbase";

// ref: https://github.com/pocketbase/js-sdk?tab=readme-ov-file#nodejs-via-npm
import eventsource from "eventsource";
// eslint-disable-next-line @typescript-eslint/no-explicit-any
(global as any).EventSource = eventsource;

type MakeFunction<T> = (data: BaseSystemFields<unknown>) => T;

export default function createPbStore<Collection extends Collections, T extends { id: string }>(
  collection: Collection,
  makeRecord: MakeFunction<T>,
  fetchOptions: { [key: string]: string } = {},
  subscribeOptions: { [key: string]: string } = fetchOptions
) {
  const { subscribe, set, update } = writable<T[]>([]);

  (async () => {
    const initialData = await pb.collection(collection).getFullList(fetchOptions);
    set(initialData.map((record: RecordModel) => makeRecord(record as BaseSystemFields<unknown>)));

    pb.collection(collection).subscribe(
      "*",
      (event) => {
        update((state) => {
          const itemIndex = state.findIndex((item) => item.id === event.record.id);
          const item = makeRecord(event.record as BaseSystemFields<unknown>);

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
  })();

  return subscribe;
}
