# Kaffediem på Svelte 🧨

Dette er kaffe-diem sitt system for å selge kaffe. Bygget med kjærlighet av elever fra [Amalie Skram](https://www.amalieskram.vgs.no).

Dette prosjektet har blitt utviklet på kodekafe. [Bli med på Discord!](https://discord.gg/HC6UMSfrJN)

- [Kontribuering](./docs/contribution.md)
- [Forklaring av sider](./docs/routes.md)
- [Arkitektur](./docs/architecture.md)

## Kjøre lokalt

Det er nyttig å enten ha Linux eller WSL.

1. Last ned [docker](https://www.docker.com/)

2. .env

```
PUBLIC_BACKEND_URL=https://kaffebase.example
PUBLIC_BACKEND_WS=wss://kaffebase.example/socket
BACKEND_URL=https://kaffebase.example
```

2. Bygg og kjør appen

```bash
make
```
