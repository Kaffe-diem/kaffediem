import PocketBase from "pocketbase";
import { PUBLIC_PB_HOST_LOCAL, PUBLIC_PB_HOST_LOCAL_DOCKER } from "$env/static/public";
import { browser } from "$app/environment";
import { type TypedPocketBase, Collections, OrderStateOptions } from "$lib/pocketbase/index.d";

// Use the browser-specific URL for client-side code, and the Docker service name for server-side
const pbUrl = browser ? PUBLIC_PB_HOST_LOCAL : PUBLIC_PB_HOST_LOCAL_DOCKER;
const pb = new PocketBase(pbUrl) as TypedPocketBase;
pb.autoCancellation(false);

export default pb;
export { Collections, OrderStateOptions };
export type * from "$lib/pocketbase/index.d";
