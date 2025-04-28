# Forklaring av ulike sider

Dette er et system for kaffe-diem for å håndtere bestilling av kaffe.

```bash
/ # Startside og menyen
├── /account # Info om din bruker: bestillinger osv.
├── /admin # Oversikt over ansattes mulige handlinger
│   ├── /menu # Redigere menyen
│   ├── /message # Redigere meldingen som vises på skjermen
│   └── /orders # Sider som omfatter bestillinger
│       ├── /frontdesk # Ta imot bestillinger
│       └── /kitchen # Se aktive bestillinger
├── /display # Storskjerm som viser info
├── /login # Innlogging
├── /logout # Utlogging
└── /tos # Vilkår for bruk
```

## Startside

Logoen til kaffe-diem og en kort beskrivelse av hva kaffe-diem er.

Her kan kunder se menyen. Den skal vise det samme som venstre kolonne av `/admin/orders/frontdesk`, i tillegg til bilder for hver ting på menyen. Man skal også kunne bestille herfra.

## /account

Viser informasjon om brukeren din.

- Profilbilde
- Navn
- Tidligere bestillinger (mulighet til å åpne på nytt)

Kunder kan også se status på sin egen bestilling.

## /admin

Oversikt for ansatte med en liste over handlingene deres. Dette er knapper for å gå til de ulike sidene under `/admin`.

### /orders

#### /frontdesk

Bestillingsdisk. Her legger ansatte til nye bestillinger. Siden er delt inn i tre kolonner:

- Liste over menyen
- Den nåværende bestillingen
  - Liste over produkter i bestillingen. Man kan trykke på et produkt i listen for å fjerne det.
  - Knapp for å legge til flere produkter, valgt i menyen.
  - Knapp for å fullføre bestilling: `"Ferdig"`.
- Liste over ferdige bestillinger som skal gis ut til kundene.

#### /kitchen

Kjøkkenet. Den er delt inn i to kolloner:

- En liste over mottatte bestillinger og bestillinger i produksjon.
- En liste over bestillinger som lages.

### /menu

Redigere menyen. Denne siden viser en liste over alt som selges, og lar ansatte endre ulike verdier.

### /message

Endring av meldingen. Denne meldingen skal vises på `/display`, og blokkerer alt annet innhold. Siden har en liste over ulike valg for hva som skal vises som meldingen. Man kan velge med en radio knapp, og endre tittel / beskrivelse med input-bokser.

## /login

Innloggingsside.

## /logout

Utlogging. Logger automatisk ut og redirecter deretter til `/´.

## /tos

Vilkår for bruk. Vi må forklare hva vi kommer til å gjøre med dataen, hva vi tar vare på og alt om personvern.
