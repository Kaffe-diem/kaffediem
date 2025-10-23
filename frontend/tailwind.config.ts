import type { Config } from "tailwindcss";
import DaisyUI from "daisyui";

export default {
  content: ["./src/**/*.{html,js,svelte,ts}"],

  theme: {
    extend: {}
  },

  plugins: [DaisyUI]
} as Config;
