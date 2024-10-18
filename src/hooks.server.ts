import { protectedRoutes } from "$lib/constants";
import { pb } from "$lib/stores/authStore";
import { redirect, type Handle } from "@sveltejs/kit";

export const handle: Handle = async ({ event, resolve }) => {
  // Load auth data from the cookie
  const cookie = event.request.headers.get("cookie") || "";
  pb.authStore.loadFromCookie(cookie);

  // List of all routes that require the user to be logged in
  const protectedRoutes = ["/account"];

  // Redirect to login if the user is not properly logged in
  if (protectedRoutes.includes(event.url.pathname) && !pb.authStore.isValid) {
    throw redirect(303, "/");
  }

  const response = await resolve(event);

  // Save auth state to cookie
  response.headers.set(
    "set-cookie",
    pb.authStore.exportToCookie({ secure: true, httpOnly: false })
  );

  return response;
};
