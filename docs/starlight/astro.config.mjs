// @ts-check
import { defineConfig } from "astro/config";
import starlight from "@astrojs/starlight";
import catppuccin from "@catppuccin/starlight";

// https://astro.build/config
export default defineConfig({
  integrations: [
    starlight({
      plugins: [
        catppuccin({
          dark: { flavor: "mocha", accent: "mauve" },
          light: { flavor: "latte", accent: "mauve" }
        })
      ],
      title: "Kaffediem Documentation",
      description: "Developer and user documentation for Kaffediem - a coffee ordering system",
      social: [
        { icon: "github", label: "GitHub", href: "https://github.com/kodekafe/kaffediem" },
        { icon: "discord", label: "Discord", href: "https://discord.gg/HC6UMSfrJN" }
      ],
      editLink: {
        baseUrl: "https://github.com/kodekafe/kaffediem/edit/main/docs/starlight/"
      },
      sidebar: [
        {
          label: "👨‍💻 Developer Docs",
          items: [
            { label: "Overview", slug: "dev" },
            {
              label: "Tutorials",
              collapsed: false,
              autogenerate: { directory: "dev/tutorials" }
            },
            {
              label: "How-To Guides",
              collapsed: true,
              autogenerate: { directory: "dev/how-to" }
            },
            {
              label: "Reference",
              collapsed: true,
              autogenerate: { directory: "dev/reference" }
            },
            {
              label: "Concepts",
              collapsed: true,
              autogenerate: { directory: "dev/concepts" }
            }
          ]
        },
        {
          label: "📱 User Guide",
          badge: "Coming Soon",
          items: [{ label: "Overview", slug: "user" }]
        }
      ],
      customCss: ["./src/styles/custom.css"]
    })
  ]
});
