# Bestillingssystem for kaffe-diem

Dette er et system for kaffe-diem for å håndtere bestilling av kaffe.

```bash
/ # Startside
├── /account # Info om din bruker: bestillinger osv.
├── /admin # Oversikt over ansattes mulige handlinger
│   ├── /frontdesk # Ta imot bestillinger
│   ├── /kitchen # Se aktive bestillinger
│   └── /message # Redigere meldingen som vises på skjermen
├── /menu # Se menyen for kunder
├── /status # Vis status av din bestilling
└── /tos # Vilkår for bruk
```

## Startside

- [x] Implementere

Logoen til kaffe-diem og en kort beskrivelse av hva kaffe-diem er.

## /account

- [ ] Implementere

Viser informasjon om brukeren din.

- Profilbilde
- Navn
- Tidligere bestillinger (mulighet til å åpne på nytt)

## /admin

- [x] Implementere

Oversikt for ansatte med en liste over handlingene deres. Dette er knapper for å gå til de ulike sidene under `/admin`.

### /admin/frontdesk

- [x] Implementere

Bestillingsdisk. Her legger ansatte til nye bestillinger. Siden er delt inn i tre kolonner:

- Liste over menyen
- Den nåværende bestillingen
  - Liste over produkter i bestillingen. Man kan trykke på et produkt i listen for å fjerne det.
  - Knapp for å legge til flere produkter, valgt i menyen.
  - Knapp for å fullføre bestilling: `"Ferdig"`.
- Liste over ferdige bestillinger som skal gis ut til kundene.

### /admin/kitchen

- [ ] Implementere

En liste over mottatte bestillinger og bestillinger i produksjon.

### /admin/message

- [x] Implementere

Endring av meldingen. Denne meldingen skal vises på `/display`, og blokkerer alt annet innhold. Siden har en liste over ulike valg for hva som skal vises som meldingen. Man kan velge med en radio knapp, og endre tittel / beskrivelse med input-bokser.

### /menu

- [ ] Implementere

Her kan kunder se menyen. Den skal vise det samme som venstre kolonne av `/admin/frontdesk`, i tillegg til bilder for hver ting på menyen. Man skal også kunne bestille herfra.

### /status

- [ ] Implementere

Kunder kan se status på sin egen bestilling gjort fra `/menu`. Den går mellom ulike states:

- Received
- Production
- Completed
- Dispatched

### /tos

- [x] Implementere

Vilkår for bruk. Vi må forklare hva vi kommer til å gjøre med dataen, hva vi tar vare på og alt om personvern.
