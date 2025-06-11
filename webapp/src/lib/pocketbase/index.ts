import PocketBase from "pocketbase";
import { type TypedPocketBase, Collections, OrderStateOptions } from "$lib/pocketbase/index.d";
import { getPocketBasePath } from "$lib/utils/pocketbase";

const pbUrl = getPocketBasePath();

const pb = new PocketBase(pbUrl) as TypedPocketBase;

pb.autoCancellation(false);

export default pb;
export { Collections, OrderStateOptions };
export type * from "$lib/pocketbase/index.d";
