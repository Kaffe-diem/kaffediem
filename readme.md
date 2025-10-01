# Kaffediem på Svelte 🧨

Dette er kaffe-diem sitt system for å selge kaffe. Bygget med kjærlighet av elever fra [Amalie Skram](https://www.amalieskram.vgs.no).

Dette prosjektet har blitt utviklet på kodekafe. [Bli med på Discord!](https://discord.gg/HC6UMSfrJN)

- [Kontribuering](./docs/contribution.md)
- [Forklaring av sider](./docs/routes.md)
- [Arkitektur](./docs/architecture.md)

## Kjøre lokalt

Det er nyttig å enten ha Linux eller WSL.

1. Last ned [docker](https://www.docker.com/)

2. Bygg og kjør appen

```bash
make
```

3. Logg inn med `example@example.com` og `basic123`

Dette brukes både på [pocketbase kontrollpanelet](http://127.0.0.1:8081/_) og [nettsiden](http://127.0.0.1:5173)

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

### Jeg kan ikke logge inn!!! (pocketbase eller nettsiden)

Pass på at du faktisk kjører koden med `make`.
Prøv å kjøre `pocketbase migrate up`
Hvis `No new migrations to apply.` prøv å `pocketbase migrate down` også `pocketbase migrate up` igjen
