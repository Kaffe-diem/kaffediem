import PocketBase from "pocketbase";
import { PUBLIC_PB_HOST } from "$env/static/public";

const pb = new PocketBase(PUBLIC_PB_HOST);

export default pb;