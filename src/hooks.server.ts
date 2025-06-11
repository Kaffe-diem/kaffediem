import PocketBase from "pocketbase";

import { restrictedRoutes, adminRoutes } from "$lib/constants";
import { redirect, type Handle } from "@sveltejs/kit";
import { sequence } from "@sveltejs/kit/hooks";
import { Collections } from "$lib/pocketbase";
import { getPocketBasePath } from "$lib/utils/pocketbase";

export const authentication: Handle = async ({ event, resolve }) => {
  // Does not work with the shared pb
  // NOTE: should get rid of that shared state anyways..
  // This instance of pb is only used for authentication purposes, everything else uses the shared one.

  const pbUrl = getPocketBasePath();
  event.locals.pb = new PocketBase(pbUrl);
  event.locals.pb.authStore.loadFromCookie(`pb_auth=${event.cookies.get("pb_auth") || ""}`);

  try {
    if (event.locals.pb.authStore.isValid)
      event.locals.pb.collection(Collections.User).authRefresh();
  } catch {
    event.locals.pb.authStore.clear();
  }

  const response = await resolve(event);

  response.headers.append(
    "set-cookie",
    event.locals.pb.authStore.exportToCookie({ httpOnly: false })
  );

  return response;
};

export const authorization: Handle = async ({ event, resolve }) => {
  const isAuthenticated = event.locals.pb.authStore.isValid;
  const isRestricted = restrictedRoutes.some((path) => event.url.pathname.includes(path));
  if (isRestricted && !isAuthenticated) {
    throw redirect(303, "/");
  }

  const isAdmin = event.locals.pb.authStore.model?.is_admin;
  const requiresAdmin = adminRoutes.some((path) => event.url.pathname.includes(path));
  if (requiresAdmin && !isAdmin) {
    throw redirect(303, "/");
  }

  return await resolve(event);
};

export const handle = sequence(authentication, authorization);
