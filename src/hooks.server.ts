import { redirect, type Handle } from "@sveltejs/kit";
import PocketBase from "pocketbase";
import { building } from "$app/environment";
import { PUBLIC_PB_HOST } from "$env/static/public";

// Kjører på hver page navigation
export const handle: Handle = async ({ event, resolve }) => {
  // Reset verdier
  event.locals.id = "";
  event.locals.email = "";
  event.locals.pb = new PocketBase(PUBLIC_PB_HOST);

  // Logge ut hvis man går til /login (slipper å skrive ekstra logikk for det)
  const isAuth: boolean = event.url.pathname === "/login";
  if (isAuth || building) {
    event.cookies.set("pb_auth", "", { path: "/" });
    return await resolve(event);
  }

  // Lese cookie og authorize pocketbase
  const pb_auth = event.request.headers.get("cookie") ?? "";
  event.locals.pb.authStore.loadFromCookie(pb_auth);

  if (!event.locals.pb.authStore.isValid) {
    // Session expired
    throw redirect(303, "/login");
  }
  try {
    const auth = await event.locals.pb
      .collection("users")
      .authRefresh<{ id: string; email: string }>();
    event.locals.id = auth.record.id;
    event.locals.email = auth.record.email;
  } catch {
    throw redirect(303, "/login");
  }

  if (!event.locals.id) {
    throw redirect(303, "/login");
  }

  const response = await resolve(event);
  const cookie = event.locals.pb.authStore.exportToCookie({ sameSite: "lax" });
  response.headers.append("set-cookie", cookie);
  return response;
};
