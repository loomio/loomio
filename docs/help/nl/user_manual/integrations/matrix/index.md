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
  introduction: bbd847d4e8bc031f
title_source: 76a2171c057b730f
title_generated: 76a2171c057b730f
---

<!-- translation-section: introduction -->

# Matrix-integratie

Loomio kan meldingen naar een Matrix-chatruimte sturen bij nieuwe discussies, peilingen, reacties, stemmen en conclusies. Je moet een groepsadmin zijn om een chatintegratie toe te voegen.

In tegenstelling tot de andere chatintegraties van Loomio gebruikt Matrix geen webhook. Loomio maakt verbinding via een Matrix-gebruikersaccount dat als bot werkt en opgemaakte berichten in jouw chatruimte plaatst.

Deze handleiding gebruikt de Element-client.

---

1. Maak een Matrix-gebruikersaccount aan voor Loomio, log ermee in bij Element en nodig dat account uit voor de Matrix-chatruimte waar je meldingen wilt ontvangen. Blijf ingelogd met deze sessie — uitloggen maakt het toegangstoken ongeldig.

2. Open in jouw Loomio-groep het groepsmenu, selecteer **Chatintegraties** en voeg een **Matrix**-chatintegratie toe.

   ![Menu voor de Loomio Matrix-bot](loomio-add-matrix-bot.png)

   ![Formulier voor de Loomio Matrix-bot](loomio-matrix-bot-form.png)

3. Open in Element het menu van het botaccount en selecteer **Alle instellingen**.

   ![Instellingenmenu van Matrix](matrix-settings-menu.png)

4. Open **Help en info** en scrol naar de sectie **Geavanceerd**.

   ![Matrix-instellingen](matrix-settings.png)

5. Kopieer het **Toegangstoken** en plak het in het Loomio-formulier.

   ![Matrix-toegangstoken](matrix-access-token.png)

6. Open het menu **Instellingen** van de chatruimte en ga naar **Geavanceerd**.

   ![Instellingen van de Matrix-chatruimte](matrix-room-settings.png)

7. Kopieer de **Interne chatruimte-ID**, plak deze in het Loomio-formulier en sla de integratie op.

   ![ID van de Matrix-chatruimte](matrix-room-id.png)
