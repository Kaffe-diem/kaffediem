import { pb } from "$lib/stores/authStore";

export const load = async ({ fetch }) => ({
  displayMessages: await pb.collection("displayMessages").getFullList({ fetch }),
  activeMessage: await pb.collection("activeMessage").getFullList({ fetch })
});
