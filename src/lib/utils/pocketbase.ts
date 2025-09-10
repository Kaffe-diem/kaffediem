import { browser } from "$app/environment";
import { PUBLIC_PB_HOST } from "$env/static/public";

export const getPocketBasePath = (): string => {
  if (!browser) {
    return "http://pb:8081";
  }

  const { hostname } = window.location;

  if (hostname === "kaffediem.okpl.us") {
    return PUBLIC_PB_HOST;
  }

  if (hostname.endsWith(".kaffediem.okpl.us")) {
    const subdomain = hostname.split(".")[0];
    try {
      const baseUrl = new URL(PUBLIC_PB_HOST);
      baseUrl.hostname = `${subdomain}.${baseUrl.hostname}`;
      return baseUrl.href.replace(/\/$/, "");
    } catch {
      return PUBLIC_PB_HOST;
    }
  }

  if (hostname.endsWith(".app.github.dev")) {
    const match = hostname.match(/^(.*)-\d+\.app\.github\.dev$/);
    if (match) {
      return `https://${match[1]}-8081.app.github.dev`;
    }
    return `https://${hostname}`;
  }

  if (hostname === "localhost" || hostname === "127.0.0.1") {
    return "http://127.0.0.1:8081";
  }

  return "http://0.0.0.0:8081";
};
