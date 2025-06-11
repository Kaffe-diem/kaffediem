import { PUBLIC_PB_HOST } from "$env/static/public";
import { dev, browser } from "$app/environment";

export const getPocketBasePath = (): string => {
  console.log(`[getPocketBasePath] dev: ${dev}, browser: ${browser}`);
  console.log(`[getPocketBasePath] PUBLIC_PB_HOST: ${PUBLIC_PB_HOST}`);
  const pbUrl =
    dev && !browser
      ? PUBLIC_PB_HOST.replace(/:\/\/(localhost|0\.0\.0\.0|127\.0\.0\.1):/, "://pb:")
      : PUBLIC_PB_HOST;
  console.log(`[getPocketBasePath] Determined PocketBase URL: ${pbUrl}`);
  return pbUrl;
};
