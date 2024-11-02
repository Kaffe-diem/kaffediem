import { pb } from "$lib/stores/authStore";

export const load = async ({ fetch }) => {
  try {
    const visibleScreenMessage = await pb
      .collection("screen_message")
      .getFirstListItem("isVisible = true", { fetch });

    return { visibleScreenMessage };
  } catch {
    return { visibleScreenMessage: null };
  }
};
