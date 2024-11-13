import pb from "$lib/pocketbase";

export const load = async ({ fetch }) => ({
  drinks: await pb.collection("drinks").getFullList({
    sort: "-created",
    fetch
  })
});
