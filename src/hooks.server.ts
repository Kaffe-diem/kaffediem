import { restrictedRoutes, adminRoutes } from "$lib/constants";
import { env } from "$env/dynamic/private";

const backendUrl = sanitizeBackendUrl(
  env.BACKEND_URL || env.PUBLIC_BACKEND_URL || "http://backend:4000"
);

export const handle: import("@sveltejs/kit").Handle = async ({ event, resolve }) => {
  const sessionRecord = await getSession(event);
  event.locals.user = sessionRecord;

  const isAuthenticated = Boolean(sessionRecord?.id);
  const isRestricted = restrictedRoutes.some((path) => event.url.pathname.startsWith(path));

  if (isRestricted && !isAuthenticated) {
    return Response.redirect(new URL("/", event.url), 303);
  }

  const requiresAdmin = adminRoutes.some((path) => event.url.pathname.startsWith(path));
  const isAdmin = Boolean(sessionRecord?.is_admin);

  if (requiresAdmin && !isAdmin) {
    return Response.redirect(new URL("/", event.url), 303);
  }

  return resolve(event);
};

async function getSession(event: Parameters<import("@sveltejs/kit").Handle>[0]["event"]) {
  const url = buildBackendUrl("/api/session");

  try {
    const response = await fetch(url, {
      method: "GET",
      headers: {
        cookie: event.request.headers.get("cookie") ?? ""
      },
      credentials: "include"
    });

    if (response.status === 204) {
      return null;
    }

    if (!response.ok) {
      return null;
    }

    const data = await response.json();
    return data?.record ?? null;
  } catch (error) {
    console.error("Failed to retrieve session", error);
    return null;
  }
}

function buildBackendUrl(path: string) {
  if (!backendUrl) {
    return path;
  }

  return new URL(path, backendUrl).toString();
}

function sanitizeBackendUrl(url: string | undefined) {
  if (!url || url.length === 0) return "";

  try {
    const parsed = new URL(url);
    parsed.pathname = parsed.pathname.replace(/\/$/, "");
    return parsed.toString();
  } catch (error) {
    console.warn("Invalid BACKEND_URL", error);
    return "";
  }
}
