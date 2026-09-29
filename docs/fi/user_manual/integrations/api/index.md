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
  introduction: 52e122013d4d71a7
  user-api: 8d42ca6c4b59b092
  server-api: a497b8e420d7881a
title_source: c8e5998f6a3955c2
title_generated: c8e5998f6a3955c2
---

<!-- translation-section: introduction -->

# Loomion API

Loomion API:n avulla voit yhdistää Loomion muihin ohjelmistoihin ja automatisoituihin työnkulkuihin.

[OpenAPI 3.1 -määrittely](openapi.yaml) kuvaa kaikki julkiset käyttäjä-API:n ja palvelin-API:n toiminnot koneluettavassa muodossa. Tuo se API-asiakasohjelmaan tai käytä sitä tyypitetyn asiakaskoodin luomiseen. Alla olevat oppaat selittävät työnkulkuja, käyttöoikeuksia ja toimintaa, joita määrittely ei kuvaa kokonaan.

<!-- translation-section: user-api -->

## Käyttäjä-API

[Käyttäjä-API](/en/user_manual/integrations/api/user-api) tekee toimintoja Loomion käyttäjänä. Sen avulla voit luetella ryhmiä sekä luoda ja hallita keskusteluketjuja, kommentteja, kyselyjä ja ryhmien jäsenyyksiä käyttäjän käyttöoikeuksien mukaan.

Tapahtumia vastaanottavissa integraatioissa [ryhmän webhookit](/en/user_manual/integrations/api/user-api#webhooks) lähettävät valitut Loomion tapahtumat verkkopäätepisteeseen JSON-muodossa. Käytä REST-päätepisteitä Loomion tietojen lukemiseen tai muuttamiseen. Käytä webhookia, kun integraation pitää vastaanottaa tapahtumia ilman jatkuvia kyselyjä.

<!-- translation-section: server-api -->

## Palvelin-API

[Palvelin-API:n](/en/user_manual/integrations/api/server-api) avulla itse ylläpidettyjen Loomio-asennusten ylläpitäjät voivat hallita käyttäjätilejä. Tunnistautuminen tapahtuu koko palvelimen yhteisellä salaisella avaimella.
