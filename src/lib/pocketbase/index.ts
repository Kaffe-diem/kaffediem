import PocketBase from "pocketbase";
import { PUBLIC_PB_HOST } from "$env/static/public";
import type { TypedPocketBase } from "$lib/pb.d";

const pb = new PocketBase(PUBLIC_PB_HOST) as TypedPocketBase;
pb.autoCancellation(false);

export default pb;
