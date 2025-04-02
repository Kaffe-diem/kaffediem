import PocketBase from "pocketbase";
import { PUBLIC_PB_HOST } from "$env/static/public";
import { browser } from "$app/environment";
import { type TypedPocketBase, Collections, OrderStateOptions } from "$lib/pocketbase/index.d";

// Use localhost for client-side code (browser), and the Docker service name for server-side
const pbUrl = browser ? PUBLIC_PB_HOST.replace('http://pb:', 'http://localhost:') : PUBLIC_PB_HOST;
const pb = new PocketBase(pbUrl) as TypedPocketBase;
pb.autoCancellation(false);

export default pb;
export { Collections, OrderStateOptions };
export type * from "$lib/pocketbase/index.d";
