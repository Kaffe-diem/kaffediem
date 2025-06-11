import { writable } from "svelte/store";
import pb from "$lib/pocketbase/";
import { User } from "$lib/types";

const auth = writable({
  isAuthenticated: pb.authStore.isValid,
  user: User.fromPb(pb.authStore.model)
});

pb.authStore.onChange(() => {
  auth.set({
    isAuthenticated: pb.authStore.isValid,
    user: User.fromPb(pb.authStore.model)
  });
});

if (typeof document !== "undefined") {
  pb.authStore.loadFromCookie(document.cookie);
}

export default auth;

export function logout() {
  pb.authStore.clear();
  document.cookie = pb.authStore.exportToCookie();
}
