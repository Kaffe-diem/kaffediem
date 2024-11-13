import pb from "$lib/pocketbase";

export const load = async ({ fetch }) => ({
  displayMessages: await pb.collection("displayMessages").getFullList({ fetch }),
  activeMessage: await pb.collection("activeMessage").getFullList({ fetch })
});
