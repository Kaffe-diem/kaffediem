import { pb } from "$lib/stores/authStore";

export const load = async ({ fetch }) => ({
  screenMessages: await pb.collection("screen_message").getFullList({ fetch })
});
