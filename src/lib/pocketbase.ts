import PocketBase from "pocketbase";
import { PUBLIC_PB_HOST } from "$env/static/public";

// Unauthenticated pocketbase instance to be used server-side
const pb = new PocketBase(PUBLIC_PB_HOST);

export default pb;
