# Kaffediem på Svelte 🧨

Dette er kaffe-diem sitt system for å selge kaffe. Bygget med kjærlighet av elever fra [Amalie Skram](https://www.amalieskram.vgs.no).

Vent litt no; er ikke du en elev på Amalie Skram? [Bli med på Discord!](https://discord.gg/HC6UMSfrJN)

## Kjøre, lokalt

Det er nyttig å enten ha Linux eller WSL.

```bash
echo "PUBLIC_PB_HOST=https://kodekafe-pocketbase.fly.dev" > .env
npm i
nvm use 20
make
```

Bemerk at node versjon 20 brukes. Det er ikke nødvendig å installere denne med NVM, men det er praktisk.

Man kan også kjøre Pocketbase lokalt via docker, dette er luddig om man skal endre på schema. Dette er via Docker, via make:

```bash
make db
```

## Din første PR 🚀

Vi har code-review for merge til main og previews på alle nye PR.

### Hva kan jeg gjøre?

Generelt sett kan du fokusere på `$lib/components`, `$lib/stores`, og `src/routes`.

Se på åpne issues og åpne pull requests.

Eller titt rundt i koden og let etter forbedringer.

# Arkitektur

![Diagram](docs/architecture.excalidraw.svg)

Bestillinger (orders) er hoveddelen av programvaren. De har fire states, som representeres deres livssyklus. Vi kan se på dette som en [tilstandsmaskin](https://en.wikipedia.org/wiki/Finite-state_machine):

```
[Received] → [Production] → [Completed] → [Dispatched]
```

Tjenester kommuniserer ikke direkte med hverandre. De sender en melding til backend. Andre tjenester lytter til visse kanaler hos backend. Når det er en oppdatering de er interessert i får de den. Generelt sett vil ikke andre tjenester lytte direkte til backend, vi isolerer mye av den logikken under `$lib/stores`. I prinsipp er dette relativt enkel implementasjon av en [event-drevet arkitektur](https://en.wikipedia.org/wiki/Event-driven_architecture).

For eksempel vil den store skjermen med hvilke bestillinger som er på vei ikke ha noe logikk selv. Den henter alt fra `$lib/orderStore`.

![display](docs/display.excalidraw.svg)

## Forskjellige gloser:

- [Pocketbase](https://pocketbase.io/). Vårt backend og persistens. Dette er en go-applikasjon som skriver til en SQLite database. Den har også en WebUI. Vi bruker en API-klient med typings.
- [Svelte](https://svelte.dev/). Et frontendrammeverk.
- [Sveltekit](https://svelte.dev/docs/kit/introduction). Ymse verktøy for Svelte, blant annet routing og muligheten for server-side kode.
- [Firebase](https://firebase.google.com/). Det vi bruker til å kjøre sveltekit, altså frontendapplikasjonen.
- [fly.io](https://fly.io). Det vi bruker til å kjøre Pocketbase, altså backendapplikasjonen.
- Ivrig på å bidra. Deg—akkurat nå.

Vi har stores som er for det meste real-time subscriptions i mot Pocketbase. Disse lar resten av applikasjonen skrive til, gjennom et fast grensesnitt, og lytte til [Server Sent Events](https://developer.mozilla.org/en-US/docs/Web/API/Server-sent_events). Dette gjør at applikasjonen oppleves som realtime, samtidig lagres alle endringer som gjøres mot persistenslaget.

Resten av interaksjon for å hente og skrive data gjøres gjennom `$lib/pocketbase` som eksporterer en singleton pocketbase-klient rettet mot `PUBLIC_PB_HOST`. Dette er trygt fordi vi har autoriseringspolicy på Pocketbase.

## Red flags ⛳️

Kodebasen beveger seg fort og vi gjør mange ting OK+ til "vi fikser det etterpå".

Designsystemet er ikke gjennomtenkt.

# Teste prod build?

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
