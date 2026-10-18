---
title: Matrix
source_revision: 924e704b41670a012a16528cf88edf90f8d6b572
source_file: docs/en/user_manual/integrations/matrix/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-01'
sections:
  introduction: e54de0b6d9ea9ffb
generated:
  introduction: efca9dc4b2044169
title_source: 76a2171c057b730f
title_generated: 76a2171c057b730f
---

<!-- translation-section: introduction -->

# Matrix-integráció

A Loomio értesítéseket küldhet a Matrix-csatornáidra, amikor új beszélgetések, javaslatok, hozzászólások, szavazatok és következtetések születnek.

A Matrix lehetővé teszi bizonyos HTML-elemek használatát a csevegőszobában, és a Loomio ezt ki is használja.

A Matrix-integrációnk kissé eltér a többi csevegőintegrációnktól: nem használ webhookot, hanem egy erre a célra készített botklienssel működik.

Hozz létre egy Matrix-felhasználói fiókot, amellyel a bot bejelentkezhet.

Miután létrehoztad a bot fiókját, jelentkezz be vele, hogy megszerezd az alábbi adatokat.

Ebben az útmutatóban az Elementet használjuk.

---

A Loomio-csoportodban adj hozzá egy Matrix-csevegőintegrációt
![A Loomio Matrix-bot menüje](loomio-add-matrix-bot.png)

Ezt az űrlapot kell kitöltened
![A Loomio Matrix-bot űrlapja](loomio-matrix-bot-form.png)

Itt kezdheted el megkeresni a hozzáférési tokenedet
![A Matrix beállítások menüje](matrix-settings-menu.png)

Ez a beállítások oldala
![A Matrix beállításai](matrix-settings.png)

Itt találod magát a hozzáférési tokent
![A Matrix hozzáférési tokenje](matrix-access-token.png)

Most a szoba azonosítójára lesz szükséged
![A Matrix-szoba beállításai](matrix-room-settings.png)

Itt találod
![A Matrix-szoba azonosítója](matrix-room-id.png)
