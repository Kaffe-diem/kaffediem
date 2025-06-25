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
		return `https://${subdomain}.kaffebase.okpl.us`;
	}

  return "http://0.0.0.0:8081";
};
