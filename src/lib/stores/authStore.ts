import { writable } from "svelte/store";
import { fetchSession, login as apiLogin, logout as apiLogout } from "$lib/api/session";
import { User } from "$lib/types";

const auth = writable({
  isAuthenticated: false,
  user: new User("", "", false)
});

async function initialise() {
  try {
    const session = await fetchSession();

    if (session?.record) {
      auth.set({ isAuthenticated: true, user: User.fromPb(session.record) });
    } else {
      auth.set({ isAuthenticated: false, user: new User("", "", false) });
    }
  } catch (error) {
    console.error("Failed to fetch session", error);
    auth.set({ isAuthenticated: false, user: new User("", "", false) });
  }
}

if (typeof window !== "undefined") {
  initialise();
}

export default auth;

export async function login(email: string, password: string) {
  const session = await apiLogin(email, password);
  auth.set({ isAuthenticated: true, user: User.fromPb(session.record) });
}

export async function logout() {
  await apiLogout();
  auth.set({ isAuthenticated: false, user: new User("", "", false) });
}
