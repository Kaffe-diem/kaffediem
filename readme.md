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
PUBLIC_PB_HOST_PROD=https://kodekafe-pocketbase.fly.dev
PB_ADMIN_EMAIL=
PB_ADMIN_PASSWORD=
```

2. Bygg og kjør appen

```bash
make
```

## Ofte stilte spørsmål

### Feilmelding når jeg kjører `make`?

Har du prøvd:

```bash
make clean
docker compose build --no-cache
```

### Koden virker ikke!!! Internal server error 500 eller ClientResponseError

Ofte har man en utdatert db (migrations blir IKKE appliet automatisk når du bytter branch)
For å apply på nytt:

```bash
make clean
make
```

### Bad gateway i prod

Problem med nginx konfigurasjon; har ingenting med koden å gjøre.
