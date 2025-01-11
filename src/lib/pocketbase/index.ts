import PocketBase from "pocketbase";
import { PUBLIC_PB_HOST } from "$env/static/public";
import { type TypedPocketBase, Collections, OrderStateOptions } from "$lib/pocketbase/index.d";

const pb = new PocketBase(PUBLIC_PB_HOST) as TypedPocketBase;
pb.autoCancellation(false);

export default pb;
export { Collections, OrderStateOptions };
export type * from "$lib/pocketbase/index.d";
