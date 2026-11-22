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
  introduction: b23350a6e9378f32
title_source: 76a2171c057b730f
title_generated: 76a2171c057b730f
---

<!-- translation-section: introduction -->

# Integrazione con Matrix

Loomio può inviare notifiche a una stanza Matrix quando vengono create nuove discussioni e nuovi sondaggi, pubblicati commenti, espressi voti e pubblicate conclusioni. Devi essere un amministratore del gruppo per aggiungere un'integrazione di chat.

A differenza delle altre integrazioni di chat di Loomio, Matrix non usa un webhook. Loomio si connette tramite un account utente Matrix che funge da bot e pubblica messaggi formattati nella tua stanza.

Questa guida usa il client Element.

---

1. Crea un account utente Matrix per Loomio, accedi con questo account in Element e invitalo nella stanza Matrix in cui vuoi ricevere le notifiche. Mantieni aperta questa sessione: uscire dall'account invalida il token di accesso.

2. Nel tuo gruppo Loomio, apri il menu del gruppo, seleziona **Integrazioni di chat** e aggiungi un'integrazione di chat **Matrix**.

   ![Menu del bot Matrix di Loomio](loomio-add-matrix-bot.png)

   ![Modulo del bot Matrix di Loomio](loomio-matrix-bot-form.png)

3. In Element, apri il menu dell'account del bot e seleziona **Tutte le impostazioni**.

   ![Menu delle impostazioni di Matrix](matrix-settings-menu.png)

4. Apri **Aiuto e informazioni** e scorri fino alla sezione **Avanzate**.

   ![Impostazioni di Matrix](matrix-settings.png)

5. Copia l'**Access Token** e incollalo nel modulo di Loomio.

   ![Token di accesso di Matrix](matrix-access-token.png)

6. Apri il menu **Configurazione** della stanza e vai a **Avanzate**.

   ![Impostazioni della stanza Matrix](matrix-room-settings.png)

7. Copia l'**ID interno della stanza**, incollalo nel modulo di Loomio e salva l'integrazione.

   ![ID della stanza Matrix](matrix-room-id.png)
