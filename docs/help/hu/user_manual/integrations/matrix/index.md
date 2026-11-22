---
title: Matrix
source_revision: ad97f553685def918a7d6e47ac5b66773de2dba8
source_file: docs/help/en/user_manual/integrations/matrix/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-11-22'
sections:
  introduction: 114ab8c916ca5fba
generated:
  introduction: 8e2273fe6a1fd2b0
title_source: 76a2171c057b730f
title_generated: 76a2171c057b730f
---

<!-- translation-section: introduction -->

# Matrix-integráció

A Loomio értesítéseket küldhet egy Matrix-szobába, amikor új beszélgetések, szavazások, hozzászólások, szavazatok és következtetések születnek. Csevegőintegráció hozzáadásához csoportadminnak kell lenned.

A Loomio többi csevegőintegrációjától eltérően a Matrix nem használ webhookot. Ehelyett a Loomio egy Matrix-felhasználói fiókon keresztül kapcsolódik, amely botként működik, és formázott üzeneteket küld a szobádba.

Ez az útmutató az Element klienst használja.

---

1. Hozz létre egy Matrix-felhasználói fiókot a Loomio számára, jelentkezz be vele az Elementben, és hívd meg ezt a fiókot abba a Matrix-szobába, ahol az értesítéseket szeretnéd látni. Maradj bejelentkezve ebben a munkamenetben — a kijelentkezés érvényteleníti a hozzáférési tokent.

2. A Loomio-csoportodban nyisd meg a csoport menüjét, válaszd ki a **Csevegési integrációk** menüpontot, és adj hozzá egy **Mátrix** csevegőintegrációt.

   ![A Loomio Matrix-bot menüje](loomio-add-matrix-bot.png)

   ![A Loomio Matrix-bot űrlapja](loomio-matrix-bot-form.png)

3. Az Elementben nyisd meg a bot fiókjának menüjét, és válaszd ki az **Összes beállítás** menüpontot.

   ![A Matrix beállítások menüje](matrix-settings-menu.png)

4. Nyisd meg a **Súgó és névjegy** menüpontot, és görgess a **Speciális** szakaszhoz.

   ![A Matrix beállításai](matrix-settings.png)

5. Másold ki a **Hozzáférési token** értékét, és illeszd be a Loomio űrlapjába.

   ![A Matrix hozzáférési tokenje](matrix-access-token.png)

6. Nyisd meg a szoba **Beállítások** menüjét, és lépj a **Speciális** szakaszra.

   ![A Matrix-szoba beállításai](matrix-room-settings.png)

7. Másold ki a **Belső szobaazonosító** értékét, illeszd be a Loomio űrlapjába, és mentsd el az integrációt.

   ![A Matrix-szoba azonosítója](matrix-room-id.png)
