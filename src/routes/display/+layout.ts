import pb from "$lib/pocketbase";

export const load = async ({ fetch }) => ({
  activeMessage: await pb.collection("activeMessage").getFullList({ expand: "message", fetch })
});
