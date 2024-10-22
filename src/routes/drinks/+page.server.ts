import upb from "$lib/pocketbase";

export const load = async () => ({
  drinks: await upb.collection("drinks").getFullList({
    sort: "-created"
  })
});
