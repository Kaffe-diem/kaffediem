import { writable } from "svelte/store";
import pb from "$lib/pocketbase/";

export const auth = writable({
  isAuthenticated: pb.authStore.isValid,
  user: pb.authStore.model
});

pb.authStore.onChange(() => {
  auth.set({
    isAuthenticated: pb.authStore.isValid,
    user: pb.authStore.model
  });
});

if (typeof document !== "undefined") {
  pb.authStore.loadFromCookie(document.cookie);
}
