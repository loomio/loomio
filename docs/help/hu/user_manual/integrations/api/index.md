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
  introduction: 9096c2983bc764e7
  user-api: 3477275d2a257029
  server-api: 0e01904f741cbe69
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

A [Szerver API](/en/user_manual/integrations/api/server-api) lehetővé teszi a saját szerveren futtatott Loomio-példányok üzemeltetőinek a felhasználói fiókok létrehozását és kezelését, a csoportok felderítését, valamint a csoporttagságok és szerepkörök kezelését. A hitelesítéshez egy, a teljes szerverre érvényes titkos kulcsot használ, és nem igényel botfiókot vagy tagságot minden egyes csoportban.
