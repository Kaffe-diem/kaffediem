import { writable } from "svelte/store";
import { fetchSession, login as apiLogin, logout as apiLogout } from "$lib/api/session";
import { User } from "$lib/types";

const anonymousUser = new User("", "", false);

const auth = writable({
  isAuthenticated: false,
  user: anonymousUser,
  isLoading: true
});

async function initialise() {
  try {
    const session = await fetchSession();

    if (session?.data) {
      auth.set({ isAuthenticated: true, user: User.fromBackend(session.data), isLoading: false });
    } else {
      auth.set({ isAuthenticated: false, user: anonymousUser, isLoading: false });
    }
  } catch (error) {
    console.error("Failed to fetch session", error);
    auth.set({ isAuthenticated: false, user: anonymousUser, isLoading: false });
  }
}

if (typeof window !== "undefined") {
  initialise();
}

export default auth;

export async function login(email: string, password: string) {
  try {
    const session = await apiLogin(email, password);

    if (!session?.data) {
      throw new Error("Ugyldig påloggingsinformasjon");
    }

    auth.set({ isAuthenticated: true, user: User.fromBackend(session.data), isLoading: false });
  } catch (error) {
    console.error("Login failed:", error);
    throw new Error("Kunne ikke logge inn. Sjekk e-post og passord.");
  }
}

export async function logout() {
  try {
    await apiLogout();
    auth.set({ isAuthenticated: false, user: anonymousUser, isLoading: false });
  } catch (error) {
    console.error("Logout failed:", error);
    // Still clear the local auth state even if the API call fails
    auth.set({ isAuthenticated: false, user: anonymousUser, isLoading: false });
  }
}
