# Kaffediem Documentation

[![Built with Starlight](https://astro.badg.es/v2/built-with-starlight/tiny.svg)](https://starlight.astro.build)

This directory contains the Starlight-powered documentation site for Kaffediem.

## Structure

```
docs/starlight/
├── src/content/docs/
│   ├── dev/          # Developer documentation
│   │   ├── tutorials/
│   │   ├── how-to/
│   │   ├── reference/
│   │   └── concepts/
│   └── user/         # User documentation (coming soon)
├── public/           # Static assets (images, SVGs)
├── Dockerfile        # Docker build config
└── nginx.conf        # nginx configuration for production
```

## Contributing

When adding new documentation:

1. Place markdown files in the appropriate directory under `src/content/docs/`
2. Add frontmatter with `title` and `description`
3. The sidebar will auto-generate from the directory structure
4. Preview your changes locally before committing

## Technology

- **Framework:** Astro + Starlight
- **Styling:** Starlight Catpuccin theme
- **Deployment:** Docker + nginx in Coolify.

## Learn More

- [Starlight Documentation](https://starlight.astro.build/)
- [Astro Documentation](https://docs.astro.build)

Built with ❤️ by [kodekafe](https://discord.gg/HC6UMSfrJN)
