import { pb } from "$lib/stores/authStore";

export const load = async ({ fetch }) => ({
  screenMessages: await pb.collection("screenMessages").getFullList({ fetch }),
  activeMessage: await pb.collection("activeMessage").getFullList({ fetch })
});
