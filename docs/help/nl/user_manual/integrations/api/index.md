---
title: API
source_revision: 2d360988a87765e6a1345dd06155bc988154178e
source_file: docs/help/en/user_manual/integrations/api/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-23'
sections:
  introduction: 99e59473b33baba1
  user-api: 8424224e38edf17f
  server-api: 42859c6715b7a994
generated:
  introduction: f0b238129d6e19b5
  user-api: 800eb661c29fe6d5
  server-api: a94145947f1d7758
title_source: c8e5998f6a3955c2
title_generated: c8e5998f6a3955c2
---

<!-- translation-section: introduction -->

# Loomio API

Gebruik de Loomio API om Loomio te verbinden met andere software en geautomatiseerde workflows.

Het [OpenAPI 3.1-contract](openapi.yaml) beschrijft elke openbare bewerking van de User API en Server API in een machineleesbaar formaat. Importeer het in een API-client of gebruik het om getypeerde clientcode te genereren. De onderstaande handleidingen leggen workflows, rechten en gedrag uit die niet volledig in het contract zijn vastgelegd.

<!-- translation-section: user-api -->

## User API

De [User API](/en/user_manual/integrations/api/user-api) voert acties uit als een Loomio-gebruiker. De API kan groepen weergeven en threads, reacties, peilingen en groepslidmaatschappen aanmaken of beheren volgens de rechten van die gebruiker.

Voor integraties op basis van pushberichten sturen [groepswebhooks](/en/user_manual/integrations/api/user-api#webhooks) geselecteerde Loomio-gebeurtenissen als JSON naar een webendpoint. Gebruik de REST-endpoints om Loomio-gegevens te lezen of te wijzigen en een webhook wanneer een integratie gebeurtenissen moet ontvangen zonder er periodiek naar te vragen.

<!-- translation-section: server-api -->

## Server API

Met de [Server API](/en/user_manual/integrations/api/server-api) kunnen beheerders van zelfgehoste Loomio-installaties gebruikersaccounts aanmaken en beheren, groepen vinden en groepslidmaatschappen en rollen beheren. De authenticatie verloopt via een geheime sleutel die voor de hele server geldt. Een botaccount of lidmaatschap van elke groep is niet vereist.
