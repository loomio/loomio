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
  introduction: 8c0a537051c63d34
  user-api: fcb0a93b540727b7
  server-api: f9c8c76208e498ff
title_source: c8e5998f6a3955c2
title_generated: c8e5998f6a3955c2
---

<!-- translation-section: introduction -->

# Loomio API

A Loomio API-val összekapcsolhatod a Loomiót más szoftverekkel és automatizált munkafolyamatokkal.

Az [OpenAPI 3.1 specifikáció](openapi.yaml) géppel olvasható formában írja le a felhasználói API és a szerver API összes nyilvános műveletét. Importáld egy API-kliensbe, vagy generálj belőle típusos klienskódot. Az alábbi útmutatók azokat a munkafolyamatokat, jogosultságokat és működési részleteket ismertetik, amelyeket a specifikáció nem ír le teljesen.

<!-- translation-section: user-api -->

## Felhasználói API

A [felhasználói API](/en/user_manual/integrations/api/user-api) egy Loomio-felhasználó nevében hajt végre műveleteket. A felhasználó jogosultságai szerint listázhatja a csoportokat, és létrehozhat vagy kezelhet témákat, hozzászólásokat, szavazásokat és csoporttagságokat.

A push-alapú integrációkhoz a [csoportos webhookok](/en/user_manual/integrations/api/user-api#webhooks) JSON-formátumban küldik el a kiválasztott Loomio-eseményeket egy webes végpontnak. A REST-végpontokkal olvashatod vagy módosíthatod a Loomio adatait. Akkor használj webhookot, ha az integrációnak rendszeres lekérdezés nélkül kell értesülnie az eseményekről.

<!-- translation-section: server-api -->

## Szerver API

A [szerver API](/en/user_manual/integrations/api/server-api) segítségével a saját szerveren futtatott Loomio-telepítések üzemeltetői kezelhetik a felhasználói fiókokat. A hitelesítéshez a teljes szerverre érvényes titkos kulcs szükséges.
