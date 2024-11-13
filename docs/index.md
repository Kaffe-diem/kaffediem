# Bestillingssystem for Kaffe Diem

Dette er et system for Kaffe Diem for å håndtere bestilling av kaffe.

## Oversikt over sider

```bash
/ # Startside
├── /account # Info om din bruker: bestillinger etc.
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

Logoen til Kaffe Diem, og en kort beskrivelse av hva de er.

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

### /admin/kitchen

- [ ] Implementere

En liste over mottatte ordre og ordre i produksjon.

### /admin/message

- [x] Implementere

Endring av meldingen. Denne meldingen skal vises på `/display`, og blokkerer alt annet innhold. Siden har en liste over ulike valg for hva som skal vises som meldingen. Man kan velge med en radio knapp, og endre title / subtitle med input-bokser.
