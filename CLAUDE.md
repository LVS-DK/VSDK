# VSDK — Interaktivt Danmarkskort over Væresteder

Internt værktøj for Landsforeningen af Væresteder (LVS) til at administrere og
visualisere foreningens netværk af væresteder på tværs af Danmarks 98 kommuner.
Repo: `LVS-DK/VSDK`. Appen bruges af kolleger i organisationen og deler ét fælles
datasæt.

## Vigtigst at vide først

- **Brugerne er ikke tekniske.** Nye felter skal have faste valgmuligheder
  (dropdowns, checkbokse) frem for fritekst, hvor det overhovedet kan lade sig gøre.
- **Brian er ikke udvikler.** Forklar kommandoer trin for trin, én ad gangen, og
  antag Windows + Kommandoprompt (ikke PowerShell).
- **Sproget i UI er dansk.** Feltnavne, knapper og fejlbeskeder skrives på dansk.
  Kode, kommentarer og commit-beskeder må gerne være på engelsk.

## Struktur

```
VSDK/
├─ public/
│  └─ index.html                      # selve appen (HTML + CSS + JS i én fil)
├─ worker.js                          # Cloudflare Worker: auth-middleware + asset-servering
├─ wrangler.toml                      # run_worker_first = true under [assets]
└─ README.md
```

Appen er bevidst **én stor single-file HTML-app** med indlejret CSS og JavaScript.
Det er ikke en fejl, der skal "ryddes op" — del den ikke op i moduler eller
introducér et build-step uden at aftale det med Brian først.

## Arkitektur

- **Frontend:** vanilla HTML/CSS/JS i `public/index.html`. Ingen framework, intet build.
- **Database:** Supabase (PostgreSQL). Skemaændringer laves med SQL-migrationsscripts,
  aldrig ved at bygge tabeller om fra bunden.
- **Hosting:** Cloudflare Workers. `worker.js` er entrypoint og håndterer
  password-beskyttelse via custom auth-middleware, før assets serveres.
- **Deploy:** push til GitHub → Cloudflares Git-integration deployer automatisk.
  Wrangler CLI bruges kun til manuelle deploys og konfiguration.
- **Kortdata:** officiel dansk DAGI GeoJSON (kommunegrænser), tegnet som SVG.

## Funktioner der findes i dag

- Interaktivt SVG-kort over alle 98 kommuner, med sidebar-navigation på region- og
  kommuneniveau og et separat København-inset, der kan foldes ud.
- Visualiseringstilstande: farvelægning af kommuner efter medlemsandel og efter
  kontingentbetaling.
- **Produktark** pr. værested med strukturerede felter: "Type værestedsbrugere",
  Tilknytning (fast dropdown: Offentligt / Privat / Frivilligt drevet),
  Finansiering (gensidigt udelukkende checkbokse: Offentlig / Privat / Delvist
  offentligt tilskud), samt Antal ansatte og Antal frivillige som intervaller
  (1–3, 4–6, 7–10, 10+).
- **Sport for Livet**: sportsbegivenheder med tilmelding pr. værested og
  multi-valg af begivenheder.
- Byråds- og mediekontakter pr. kommune.
- Eksport til Excel/CSV med valg af felter.
- **Superuser-tilstand**: aktiveres ved at skrive `BrianBrianBrian` i søgefeltet;
  låser op for administrative funktioner.

## Database — kendte tilføjelser

Kolonner tilføjet via migrationer: `note`, `kontingent_betalt`, `finansiering`,
`antal_ansatte`, `antal_frivillige`.
Tabeller: `sportsbegivenheder`, `tilmeldinger`.

Ved nye felter: skriv SQL-migrationen ud, så Brian kan køre den i Supabase'
SQL-editor, og opdatér frontend'en i samme ombæring.

## Faldgruber (lært på den hårde måde)

- **PowerShell brækker Wrangler** på grund af execution policy. Brug Kommandoprompt.
- **Cloudflare understøtter ikke zoner for et enkelt subdomæne.** Det er derfor
  `vsdk.vaeresteder.dk` aldrig kom op at køre — domænet ligger hos Design'R'Us, og
  fuld DNS-migrering til Cloudflare er ikke gennemført. Appen tilgås på
  workers.dev-URL'en indtil videre.
- **Gamle Tilknytning-værdier**, der ikke matcher de tre faste valg, falder tilbage
  til "Offentligt". Husk det ved nye migrationer.
- `run_worker_first = true` i `wrangler.toml` er nødvendig, for at auth-middleware
  kører før assets serveres. Fjern den ikke.

## Arbejdsform

Udvikling foregår i korte sessioner, hvor Brian sætter prioriteterne. Lav én ting
ad gangen, vis resultatet, og vent på feedback før næste skridt. Hvis en opgave
kræver deploy eller SQL, så skriv de præcise kommandoer ud frem for at beskrive dem.

## Åbne punkter

- En produktspecifikation blev efterladt halvfærdig: "I stedet kommer der en
  fritekstbox med…" — sætningen blev aldrig gjort færdig. Spørg Brian, hvad den
  skulle have sagt, hvis emnet dukker op.
