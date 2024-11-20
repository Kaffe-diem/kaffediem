# Kaffediem på Svelte 🧨

Dette er kaffe-diem sitt system for å selge kaffe. Bygget med kjærlighet av elever fra [Amalie Skram](https://www.amalieskram.vgs.no).

Dette prosjektet har blitt utviklet på kodekafe. [Bli med på Discord!](https://discord.gg/HC6UMSfrJN)

- [Kontribuering](./docs/contribution.md)
- [Forklaring av sider](./docs/routes.md)
- [Arkitektur](./docs/architecture.md)

## Kjøre lokalt

Det er nyttig å enten ha Linux eller WSL.

```bash
echo "PUBLIC_PB_HOST=https://kodekafe-pocketbase.fly.dev" > .env
npm i
nvm use 20
make
```

Bemerk at node versjon 20 brukes. Det er ikke nødvendig å installere denne med NVM, men det er praktisk.

Man kan også kjøre Pocketbase lokalt via docker, dette er lurt om man skal endre på schema. Dette er via Docker, via make:

```bash
make db
```

## Teste prod build?

[intern monolog: refaktorsier dette via https://github.com/Kaffe-diem/kaffediem/issues/50]

### Teste på lokal maskin

(Antar at dependencies allerede er installert)

1. Bygg appen

```bash
npm run build
```

2. Kjør appen

```bash
node build
```

### Hvis dependencies ikke er installert (for eksempel på rpi):

1. Kopier `package.json` og `package-lock.json` til `build/`

```bash
cp {package.json,package-lock.json} build/
cd build
```

2. Installer dependencies

```bash
npm ci --omit dev
```

3. Kjør serveren:

```bash
node .
```
