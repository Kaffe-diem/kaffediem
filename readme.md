# Kaffe diem frontend i svelte

## Development

### .env

PB_HOST=https://kodekafe-pocketbase.fly.dev
PB_USER=
PB_PASS=

1. Clone repoen

2. Installer dependencies

```bash
npm ci
```

3. Run dev serveren

```bash
npm run dev
npm run dev -- --host # for å åpne til nettverk
```

## Deploy

### Teste på lokal maskin

(Antar at dependencies allerede er installert)

1. Build appen

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
