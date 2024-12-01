import pb from "$lib/pocketbase";
import { writable } from "svelte/store";

// ref: https://github.com/pocketbase/js-sdk?tab=readme-ov-file#nodejs-via-npm
import eventsource from "eventsource";
// eslint-disable-next-line @typescript-eslint/no-explicit-any
(global as any).EventSource = eventsource;

export default function createPbStore<T>(
  collection: string,
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  mapFunction: (data: any) => T,
  fetchOptions: { [key: string]: string } = {},
  subscribeOptions: { [key: string]: string } = fetchOptions
) {
  const { subscribe, set, update } = writable<T[]>([]);

  (async () => {
    const initialData = await pb.collection(collection).getFullList(fetchOptions);

    set(initialData.map(mapFunction));

    pb.collection(collection).subscribe(
      "*",
      (event) => {
        update((state) => {
          // @ts-expect-error All targets of record maps should have an id.
          const itemIndex = state.findIndex((item) => item.id == event.record.id);
          const item = mapFunction(event.record);

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
