import { fail, redirect } from "@sveltejs/kit";
import type { ClientResponseError } from "pocketbase";
import type { PageServerLoad } from "./$types";
import { Collections } from "$lib/pocketbase";

export const actions = {
  login: async ({ locals, request, cookies }) => {
    const data = await request.formData();
    const email = data.get("email");
    const password = data.get("password");

    try {
      await locals.pb
        .collection(Collections.User)
        .authWithPassword(email.toString(), password.toString());
    } catch (e) {
      const error = e as ClientResponseError;
      return fail(500, { fail: true, message: error.message });
    }

    cookies.set("pb_auth", locals.pb.authStore.exportToCookie(), {
      path: "/",
      httpOnly: false,
      sameSite: "lax",
      secure: process.env.NODE_ENV === "production",
      maxAge: 60 * 60 * 24 * 7 // 7 days
    });

    throw redirect(303, "/");
  }
};

export const load = (async ({ locals }) => {
  if (locals.pb.authStore.isValid) {
    return redirect(303, "/");
  }

  return {};
}) satisfies PageServerLoad;
