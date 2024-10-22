import upb from "$lib/pocketbase";

export const load = async () => ({
  drinks: await pb.collection("drinks").getFullList({
    sort: "-created"
  })
});
