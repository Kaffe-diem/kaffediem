# Kaffediem på Svelte 🧨

Dette er kaffe-diem sitt system for å selge kaffe. Bygget med kjærlighet av elever fra [Amalie Skram](https://www.amalieskram.vgs.no).

Vent litt no; er ikke du en elev på Amalie Skram? [Bli med på Discord!](https://discord.gg/HC6UMSfrJN)

Les om de interne delene av prosjektet i [dokumentasjonen](./docs/readme.md).

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

## Teste på lokal maskin

(Antar at dependencies allerede er installert)

1. Bygg appen

```bash
npm run build
```

2. Kjør appen

```bash
node build
```

## Hvis dependencies ikke er installert (for eksempel på rpi):

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

## Din første PR 🚀

Vi har code-review for merge til main og previews på alle nye PR.

Formater koden din før du commit-er:

```bash
npm run format
```

### Hva kan jeg gjøre?

- Generelt sett kan du fokusere på `$lib/components`, `$lib/stores`, og `src/routes`.
- Se på åpne issues og åpne pull requests.
- Eller titt rundt i koden og let etter forbedringer.
