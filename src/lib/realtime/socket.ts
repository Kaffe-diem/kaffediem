import { browser } from "$app/environment";
import { PUBLIC_BACKEND_URL, PUBLIC_BACKEND_WS } from "$env/static/public";
import { Socket } from "phoenix";

let socket: Socket | null = null;

const backendWsUrl = deriveWsUrl(PUBLIC_BACKEND_WS, PUBLIC_BACKEND_URL);

export function getSocket(): Socket | null {
  if (!browser) return null;
  if (socket) return socket;

  socket = new Socket(backendWsUrl, {
    params: {}
  });

  socket.connect();
  return socket;
}

function deriveWsUrl(explicitWs: string | undefined, backendHttp: string | undefined) {
  if (explicitWs && explicitWs.length > 0) {
    return explicitWs;
  }

  if (!backendHttp || backendHttp.length === 0) {
    return "/socket";
  }

  try {
    const url = new URL(backendHttp);
    url.protocol = url.protocol === "https:" ? "wss:" : "ws:";
    url.pathname = url.pathname.replace(/\/$/, "") + "/socket";
    return url.toString();
  } catch (error) {
    console.warn("Invalid PUBLIC_BACKEND_URL", error);
    return "/socket";
  }
}
