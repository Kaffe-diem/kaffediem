import { pb } from "$lib/stores/authStore";

export const load = async ({ fetch }) => ({
  visibleScreenMessage: await pb
    .collection("screen_message")
    .getFirstListItem("isVisible=true", { fetch })
});
