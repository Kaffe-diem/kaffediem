import PocketBase from "pocketbase";
import { PUBLIC_PB_HOST } from "$env/static/public";

// Unauthenticated pocketbase instance to be used server-side
const upb = new PocketBase(PUBLIC_PB_HOST);

export default upb;
