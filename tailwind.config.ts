import type { Config } from "tailwindcss";
import DaisyUI from "daisyui";

export default {
  content: ["./src/**/*.{html,js,svelte,ts}"],

  theme: {
    extend: {}
  },

  daisyui: {
    themes: [
      {
        // Modified DaisyUI "forest" theme
        // Example themes: https://github.com/saadeghi/daisyui/blob/56313736a3eba4e12d24285caea4e1c3dbf229c1/src/theming/themes.js
        kaffeDiem: {
          primary: "#1eb854",
          secondary: "#1DB88E",
          accent: "#1DB8AB",
          neutral: "#19362D",
          "base-100": "#ffffff"
        }
      }
    ],
    darkTheme: "kaffeDiem"
  },

  plugins: [DaisyUI]
} as Config;
