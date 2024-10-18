import type { Config } from "tailwindcss";
import DaisyUI from "daisyui";

export default {
  content: ["./src/**/*.{html,js,svelte,ts}"],

  theme: {
    extend: {}
  },

  daisyui: {
    themes: ["light"],
    darkTheme: "light"
  },

  plugins: [DaisyUI]
} as Config;
