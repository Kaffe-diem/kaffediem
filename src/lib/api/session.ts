import { PUBLIC_BACKEND_URL } from "$env/static/public";

const backendBase = sanitizeBackendUrl(PUBLIC_BACKEND_URL);

export type SessionRecord = {
  record: {
    id: string;
    name?: string;
    is_admin?: boolean;
  };
};

export async function login(email: string, password: string): Promise<SessionRecord> {
  const response = await fetch(buildBackendUrl("/api/session"), {
    method: "POST",
    headers: {
      "Content-Type": "application/json"
    },
    credentials: "include",
    body: JSON.stringify({ email, password })
  });

  if (!response.ok) {
    throw new Error(`Login failed: ${response.status}`);
  }

  return response.json();
}

export async function logout(): Promise<void> {
  const response = await fetch(buildBackendUrl("/api/session"), {
    method: "DELETE",
    credentials: "include"
  });

  if (!response.ok && response.status !== 204) {
    throw new Error(`Logout failed: ${response.status}`);
  }
}

export async function fetchSession(): Promise<SessionRecord | null> {
  const response = await fetch(buildBackendUrl("/api/session"), {
    method: "GET",
    credentials: "include"
  });

  if (response.status === 204) {
    return null;
  }

  if (!response.ok) {
    throw new Error(`Failed to fetch session: ${response.status}`);
  }

  return response.json();
}

function buildBackendUrl(path: string) {
  if (!backendBase) {
    return path;
  }

  return new URL(path, backendBase).toString();
}

function sanitizeBackendUrl(url: string | undefined) {
  if (!url || url.length === 0) return "";

  try {
    const parsed = new URL(url);
    parsed.pathname = parsed.pathname.replace(/\/$/, "");
    return parsed.toString();
  } catch (error) {
    console.warn("Invalid PUBLIC_BACKEND_URL", error);
    return "";
  }
}
