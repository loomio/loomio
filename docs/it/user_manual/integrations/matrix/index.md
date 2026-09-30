---
title: Matrix
source_revision: 7a01b0fd7d7df0c4bca327a916b01b12e62b967f
source_file: docs/user_manual/integrations/matrix/index.md
translated:
  provider: codex/gpt-6-sol
  'on': '2026-09-30'
sections:
  introduction: e54de0b6d9ea9ffb
generated:
  introduction: 8485458f74116437
title_source: 76a2171c057b730f
title_generated: 76a2171c057b730f
---

<!-- translation-section: introduction -->

# Integrazione con Matrix

Loomio può inviare notifiche ai tuoi canali Matrix quando vengono create discussioni, proposte, commenti, voti e conclusioni.

Matrix consente di usare parte dell'HTML nelle chat e Loomio sfrutta questa possibilità.

L'integrazione con Matrix funziona in modo diverso dalle altre integrazioni con le chat: non usa un webhook, ma un bot creato appositamente.

Devi creare un utente Matrix che il bot possa usare per accedere.

Dopo aver creato l'utente per il bot, accedi con quell'account per ottenere le informazioni seguenti.

In questa guida usiamo Element.

---

Nel tuo gruppo Loomio, aggiungi un'integrazione con la chat Matrix
![menu del bot Matrix in Loomio](loomio-add-matrix-bot.png)

Compila questo modulo
![modulo del bot Matrix in Loomio](loomio-matrix-bot-form.png)

Da qui puoi iniziare a cercare il tuo token di accesso
![menu delle impostazioni di Matrix](matrix-settings-menu.png)

Questa è la pagina delle impostazioni
![impostazioni di Matrix](matrix-settings.png)

Qui trovi il token di accesso
![token di accesso a Matrix](matrix-access-token.png)

Ora ti serve l'ID della stanza
![impostazioni della stanza Matrix](matrix-room-settings.png)

Lo trovi qui.
![ID della stanza Matrix](matrix-room-id.png)
