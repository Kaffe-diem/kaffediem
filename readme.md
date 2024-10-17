# Kaffe diem frontend i svelte

## TODO

Etterspørseler fra ansatte:

- [ ] Finere UI (prøve å etterligne macdonalds osv)
- [ ] Gjenlage det nåverende systemet på ipaden
  - To kolonner, akkurat som display
  - Trykke på ordre -> bytte fra produksjon til ferdig til slette
  - Stor knapp for å legge til
  - Knapp for å skrive melding på display
- [ ] Det nåværende systemet lar deg også sette spesifikke meldinger på skjermen (som "stengt" hvor ansatte kan skrive hva som helst)
- [ ] Måte for ansatte å legge til ting i menyen (nye valg, sesong valg osv)
- [ ] QR-kode / lenke til denne her frontenden på skjermen
- [ ] Vise bilder i menyen

Andre ting:

- Må spørre VLFK for å få vipps konto (gjøres gjennom Mercedes og ledelsen)
- Må spørre VLFK om å tillate google-innlogging gjennom oauth
- Rundt 75% bruker kortbetalling og det er foretrukket, resten bruker vipps. Slik det virker nå må ansatte manuelt åpne vipps og sende en request
- Bruke egen kopp må virke

Sider som må til for dette:

- Main side med info om kaffe diem, links til de andre sidene
- Hoved display
- Ipad display for å endre og legge til bestillinger (kun touchskjerm)
- Endre på menyen for ansatte
- Bestilling på telefon
- Se status på telefon

## .env

```bash
PUBLIC_PB_HOST=https://kodekafe-pocketbase.fly.dev
PB_USER=
PB_PASS=
```

Testing av db i svelte:

```bash
# samme verdier som USER og PASS over
PUBLIC_PB_ADMIN_EMAIL=
PUBLIC_PB_ADMIN_PASSWORD=
```

## Development

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
