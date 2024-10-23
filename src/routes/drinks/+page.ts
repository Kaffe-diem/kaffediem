import { pb } from "$lib/stores/authStore";

export const load = async ({fetch}) => ({
  drinks: await pb.collection("drinks").getFullList({
    sort: "-created",
    fetch
  })
});
