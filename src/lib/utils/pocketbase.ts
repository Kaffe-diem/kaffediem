import { browser } from "$app/environment";

export const getPocketBasePath = (): string => {
  if (!browser) {
    return "http://pb:8081";
  }

  const { hostname } = window.location;

  if (hostname === "kaffediem.okpl.us") {
    return "https://kaffebase.okpl.us";
  }

  if (hostname.endsWith(".kaffediem.okpl.us")) {
    const subdomain = hostname.split(".")[0];
    return `http://${subdomain}.kaffebase.okpl.us`;
  }

  if (hostname === "localhost" || hostname === "127.0.0.1") {
    return "http://127.0.0.1:8081";
  }

  return "http://0.0.0.0:8081";
};
