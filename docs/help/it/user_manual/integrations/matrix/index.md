---
title: Matrix
source_revision: c6076258c3438c0dd6dc8fbf1fc0b0df47c0aeb5
source_file: docs/en/user_manual/integrations/matrix/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-01'
sections:
  introduction: e54de0b6d9ea9ffb
generated:
  introduction: d9a92b43495a6108
title_source: 76a2171c057b730f
title_generated: 76a2171c057b730f
---

<!-- translation-section: introduction -->

# Integrazione con Matrix

Loomio può inviare notifiche nei tuoi canali Matrix quando vengono create nuove discussioni e proposte, pubblicati commenti, espressi voti e pubblicate conclusioni.

Matrix consente di usare alcuni elementi HTML nella stanza di chat e Loomio sfrutta questa possibilità.

La nostra integrazione con Matrix è un po' diversa dalle altre integrazioni con le chat: non usa un webhook, ma un client bot personalizzato che abbiamo sviluppato appositamente.

Devi creare un utente Matrix con cui il bot possa accedere.

Una volta creato un utente per il bot, accedi con quell'utente per ottenere le informazioni seguenti.

Per questa guida usiamo Element.

---

Dal tuo gruppo Loomio, aggiungi un'integrazione con la chat Matrix
![Menu del bot Matrix di Loomio](loomio-add-matrix-bot.png)

Ecco il modulo da compilare
![Modulo del bot Matrix di Loomio](loomio-matrix-bot-form.png)

Ecco da dove iniziare per trovare il tuo token di accesso
![Menu delle impostazioni di Matrix](matrix-settings-menu.png)

Ecco la pagina delle impostazioni
![Impostazioni di Matrix](matrix-settings.png)

Ecco il token di accesso
![Token di accesso di Matrix](matrix-access-token.png)

Ora ti serve l'ID della stanza
![Impostazioni della stanza Matrix](matrix-room-settings.png)

Eccolo.
![ID della stanza Matrix](matrix-room-id.png)
