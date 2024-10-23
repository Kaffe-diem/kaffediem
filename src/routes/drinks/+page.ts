import { pb } from "$lib/stores/authStore";

export const load = async () => ({
  drinks: await pb.collection("drinks").getFullList({
    sort: "-created"
  })
});
