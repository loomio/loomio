---
title: API
source_revision: 7a01b0fd7d7df0c4bca327a916b01b12e62b967f
source_file: docs/user_manual/integrations/api/index.md
translated:
  provider: codex/gpt-6-sol
  'on': '2026-09-30'
sections:
  introduction: 99e59473b33baba1
  user-api: 8424224e38edf17f
  server-api: f1bf07c1162ff08b
generated:
  introduction: f279dd4162824872
  user-api: 453bfed92c1dbc03
  server-api: e63424eb68c5594f
title_source: c8e5998f6a3955c2
title_generated: c8e5998f6a3955c2
---

<!-- translation-section: introduction -->

# Loomio API

Gebruik de Loomio API om Loomio te verbinden met andere software en geautomatiseerde werkprocessen.

Het [OpenAPI 3.1-contract](openapi.yaml) beschrijft alle openbare bewerkingen van de gebruikers-API en server-API in een formaat dat software kan lezen. Importeer het in een API-client of gebruik het om clientcode met typen te genereren. De handleidingen hieronder leggen werkprocessen, rechten en gedrag uit die niet volledig in het contract zijn beschreven.

<!-- translation-section: user-api -->

## Gebruikers-API

Met de [gebruikers-API](/en/user_manual/integrations/api/user-api) voer je acties uit als Loomio-gebruiker. Je kunt groepen opvragen en threads, reacties, polls en groepslidmaatschappen aanmaken of beheren, afhankelijk van je rechten.

Voor integraties die automatisch updates ontvangen, sturen [groepswebhooks](/en/user_manual/integrations/api/user-api#webhooks) geselecteerde Loomio-gebeurtenissen als JSON naar een webadres. Gebruik de REST-eindpunten om Loomio-gegevens te lezen of te wijzigen. Gebruik een webhook als een integratie gebeurtenissen moet ontvangen zonder steeds zelf nieuwe gegevens op te vragen.

<!-- translation-section: server-api -->

## Server-API

Met de [server-API](/en/user_manual/integrations/api/server-api) kunnen beheerders van zelf gehoste Loomio-installaties gebruikersaccounts beheren. Voor toegang is een geheim vereist dat voor de hele server geldt.
