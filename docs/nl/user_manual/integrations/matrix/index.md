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
  introduction: a6eaaadcf822422c
title_source: 76a2171c057b730f
title_generated: 76a2171c057b730f
---

<!-- translation-section: introduction -->

# Matrix-integratie

Loomio kan meldingen naar jouw Matrix-kanalen sturen bij nieuwe discussies, voorstellen, reacties, stemmen en conclusies.

Matrix ondersteunt bepaalde HTML in de chatruimte, en Loomio maakt daar gebruik van.

Onze Matrix-integratie werkt iets anders dan onze andere chatintegraties: deze gebruikt geen webhook. We hebben hiervoor een eigen botclient gebouwd.

Maak een Matrix-gebruiker aan waarmee de bot kan inloggen.

Log na het aanmaken van de gebruiker voor de bot in met dat account om de volgende gegevens op te halen.

Voor deze handleiding gebruiken we Element.

---

Voeg vanuit jouw Loomio-groep een Matrix-chatintegratie toe
![Menu voor de Loomio Matrix-bot](loomio-add-matrix-bot.png)

Dit is het formulier dat je moet invullen
![Formulier voor de Loomio Matrix-bot](loomio-matrix-bot-form.png)

Hier begin je met het zoeken naar jouw toegangstoken
![Instellingenmenu van Matrix](matrix-settings-menu.png)

Dit is de instellingenpagina
![Matrix-instellingen](matrix-settings.png)

Dit is het toegangstoken zelf
![Matrix-toegangstoken](matrix-access-token.png)

Nu heb je de ID van de chatruimte nodig
![Instellingen van de Matrix-chatruimte](matrix-room-settings.png)

Hier vind je die.
![ID van de Matrix-chatruimte](matrix-room-id.png)
