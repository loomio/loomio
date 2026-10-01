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
  introduction: 9096c2983bc764e7
  user-api: 3477275d2a257029
  server-api: 522320465c9f1c63
title_source: c8e5998f6a3955c2
title_generated: c8e5998f6a3955c2
---

<!-- translation-section: introduction -->

# Loomio API

Használd a Loomio API-t a Loomio más szoftverekkel és automatizált munkafolyamatokkal való összekapcsolásához.

Az [OpenAPI 3.1 specifikáció](openapi.yaml) géppel olvasható formátumban írja le a Felhasználói API és a Szerver API összes nyilvános műveletét. Importáld egy API-kliensbe, vagy használd típusos klienskód generálásához. Az alábbi útmutatók olyan munkafolyamatokat, jogosultságokat és működési részleteket ismertetnek, amelyeket a specifikáció nem ír le teljesen.

<!-- translation-section: user-api -->

## Felhasználói API

A [Felhasználói API](/en/user_manual/integrations/api/user-api) egy Loomio-felhasználó nevében hajt végre műveleteket. A felhasználó jogosultságainak megfelelően listázhat csoportokat, valamint létrehozhat és kezelhet szálakat, hozzászólásokat, szavazásokat és csoporttagságokat.

Az eseményküldésen alapuló integrációkhoz a [csoportok webhookjai](/en/user_manual/integrations/api/user-api#webhooks) JSON formátumban küldik el a kiválasztott Loomio-eseményeket egy webes végpontra. Használd a REST-végpontokat a Loomio adatainak olvasásához vagy módosításához, és használj webhookot, ha az integrációnak rendszeres lekérdezés nélkül kell fogadnia az eseményeket.

<!-- translation-section: server-api -->

## Szerver API

A [Szerver API](/en/user_manual/integrations/api/server-api) lehetővé teszi a saját szerveren futtatott Loomio-példányok üzemeltetőinek a felhasználói fiókok kezelését. A hitelesítéshez egy, a teljes szerverre érvényes titkos kulcsot használ.
