import { browser } from "$app/environment";
import { Socket } from "phoenix";

let socket: Socket | null = null;

export function getSocket(): Socket | null {
  if (!browser) return null;
  if (socket) return socket;

  socket = new Socket("/socket", {
    params: {},
    withCredentials: true
  });

  socket.connect();
  return socket;
}
