import pb from "$lib/pocketbase";

export const load = async () => {
  return {
    drinks: await pb.collection("drinks").getFullList({
      sort: "-created"
    })
  };
};
