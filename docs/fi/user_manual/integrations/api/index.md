---
title: API
source_revision: 924e704b41670a012a16528cf88edf90f8d6b572
source_file: docs/en/user_manual/integrations/api/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-01'
sections:
  introduction: 99e59473b33baba1
  user-api: 8424224e38edf17f
  server-api: f1bf07c1162ff08b
generated:
  introduction: 40d54e28138a3125
  user-api: d221fd02d9c02039
  server-api: b4bc50d257f8498b
title_source: c8e5998f6a3955c2
title_generated: c8e5998f6a3955c2
---

<!-- translation-section: introduction -->

# Loomio API

Yhdistä Loomio muihin ohjelmistoihin ja automatisoituihin työnkulkuihin Loomion API:n avulla.

[OpenAPI 3.1 -määrittely](openapi.yaml) kuvaa kaikki julkisen käyttäjä-API:n ja palvelin-API:n toiminnot koneellisesti luettavassa muodossa. Tuo se API-asiakasohjelmaan tai käytä sitä tyypitetyn asiakaskoodin luomiseen. Alla olevat oppaat selittävät työnkulkuja, käyttöoikeuksia ja toimintaa, joita määrittely ei kuvaa kokonaan.

<!-- translation-section: user-api -->

## Käyttäjä-API

[Käyttäjä-API](/en/user_manual/integrations/api/user-api) suorittaa toimintoja Loomio-käyttäjänä. Sen avulla voit luetella ryhmiä sekä luoda tai hallita ketjuja, kommentteja, kyselyjä ja ryhmäjäsenyyksiä kyseisen käyttäjän käyttöoikeuksien mukaisesti.

Push-pohjaisissa integraatioissa [ryhmän webhookit](/en/user_manual/integrations/api/user-api#webhooks) lähettävät valitut Loomio-tapahtumat verkko-osoitteeseen JSON-muodossa. Käytä REST-päätepisteitä Loomion tietojen lukemiseen tai muuttamiseen ja webhookia, kun integraation pitää vastaanottaa tapahtumia ilman toistuvia tarkistuspyyntöjä.

<!-- translation-section: server-api -->

## Palvelin-API

[Palvelin-API](/en/user_manual/integrations/api/server-api) antaa omalla palvelimella ylläpidettyjen Loomio-asennusten ylläpitäjille mahdollisuuden hallita käyttäjätilejä. Todennukseen käytetään koko palvelimen yhteistä salaisuutta.
