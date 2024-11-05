import { restrictedRoutes, adminRoutes } from "$lib/constants";
import { pb } from "$lib/stores/authStore";
import { redirect, type Handle } from "@sveltejs/kit";

export const handle: Handle = async ({ event, resolve }) => {
  const cookie = event.request.headers.get("cookie") || "";
  pb.authStore.loadFromCookie(cookie);

  const isAuthenticated = pb.authStore.isValid;
  const isRestricted = restrictedRoutes.some((path) => event.url.pathname.includes(path));
  if (isRestricted && !isAuthenticated) {
    throw redirect(303, "/");
  }

  const isAdmin = pb.authStore.model?.is_admin;
  const requiresAdmin = adminRoutes.some((path) => event.url.pathname.includes(path));
  if (requiresAdmin && !isAdmin) {
    throw redirect(303, "/");
  }

  const response = await resolve(event);

  response.headers.set(
    "set-cookie",
    pb.authStore.exportToCookie({ secure: true, httpOnly: false })
  );

  return response;
};
