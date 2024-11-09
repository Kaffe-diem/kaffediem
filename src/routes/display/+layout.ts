import { pb } from "$lib/stores/authStore";

export const load = async ({ fetch }) => ({
  activeMessage: await pb.collection("activeMessage").getFullList({ expand: "message", fetch })
});
