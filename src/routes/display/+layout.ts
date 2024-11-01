import { pb } from "$lib/stores/authStore";

export const load = async ({ fetch }) => ({
  screenMessageRecord: await pb.collection("screen_message").getFullList({ fetch })
});
