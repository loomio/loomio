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
  introduction: e96df5b9f72b5829
title_source: 76a2171c057b730f
title_generated: 76a2171c057b730f
---

<!-- translation-section: introduction -->

# Matrix-integraatio

Loomio voi lähettää ilmoituksia Matrix-huoneeseen uusista keskusteluista, kyselyistä, kommenteista, äänistä ja johtopäätöksistä. Sinun on oltava ryhmän ylläpitäjä, jotta voit lisätä chat-integraation.

Toisin kuin Loomion muut chat-integraatiot, Matrix ei käytä webhookia. Sen sijaan Loomio muodostaa yhteyden Matrix-käyttäjätilin kautta, joka toimii bottina ja lähettää muotoiltuja viestejä huoneeseesi.

Tässä ohjeessa käytetään Element-sovellusta.

---

1. Luo Loomiolle Matrix-käyttäjätili, kirjaudu sillä sisään Elementiin ja kutsu tili Matrix-huoneeseen, johon haluat ilmoitukset. Pidä tämä istunto kirjautuneena sisään — uloskirjautuminen mitätöi käyttöoikeustunnuksen.

2. Avaa Loomio-ryhmäsi valikko, valitse **Chat-integraatiot** ja lisää **Matriisi**-chat-integraatio.

   ![Loomion Matrix-botin valikko](loomio-add-matrix-bot.png)

   ![Loomion Matrix-botin lomake](loomio-matrix-bot-form.png)

3. Avaa Elementissä botin tilivalikko ja valitse **Kaikki asetukset**.

   ![Matrixin asetusvalikko](matrix-settings-menu.png)

4. Avaa **Ohje ja tietoja** ja vieritä kohtaan **Lisäasetukset**.

   ![Matrixin asetukset](matrix-settings.png)

5. Kopioi **Käyttöoikeustunnus** ja liitä se Loomion lomakkeeseen.

   ![Matrixin käyttöoikeustunnus](matrix-access-token.png)

6. Avaa huoneen **asetukset**-valikko ja siirry kohtaan **Lisäasetukset**.

   ![Matrix-huoneen asetukset](matrix-room-settings.png)

7. Kopioi **Huoneen sisäinen tunniste**, liitä se Loomion lomakkeeseen ja tallenna integraatio.

   ![Matrix-huoneen tunniste](matrix-room-id.png)
