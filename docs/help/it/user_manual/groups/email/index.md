---
title: Indirizzo email
source_revision: 95ce9afd64c99656f67e05a09fa9fc8a77af51d7
source_file: docs/help/en/user_manual/groups/email/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-11-26'
sections:
  introduction: 36b06c5b4604ac74
  preventing-unauthorized-emails: f4b8d2eaf0d79f01
generated:
  introduction: 3d26e38289b8553a
  preventing-unauthorized-emails: 7ce5e307bcd94da4
title_source: f2488fd4ef4adbc6
title_generated: 5df4aa5fa0b18311
---

<!-- translation-section: introduction -->

# Invia un'email per avviare una conversazione nel tuo gruppo

Ogni gruppo Loomio ha un proprio indirizzo email. Puoi inviare o inoltrare un'email a questo indirizzo per avviare una nuova conversazione nel gruppo.

Puoi trovare l'indirizzo email del gruppo sotto **Configurazione** nella pagina del gruppo:

![Posizione dell'indirizzo email sotto Configurazione nella pagina del gruppo](email_email_button.png)

Quando invii un'email a questo indirizzo, Loomio crea una nuova conversazione. L'oggetto dell'email diventa il titolo della conversazione, il corpo diventa la descrizione della conversazione e gli eventuali file allegati vengono aggiunti alla conversazione.

Loomio usa l'indirizzo nel campo "Da" dell'email per identificare il mittente come membro del gruppo e impostarlo come autore della conversazione.

<!-- translation-section: preventing-unauthorized-emails -->

## Impedire l'invio di email non autorizzate

Per impedire a chi non è membro del gruppo di avviare conversazioni, Loomio richiede che l'indirizzo nel campo "Da" di un'email in arrivo corrisponda all'indirizzo email di un membro del gruppo.

Se un membro invia un'email da un indirizzo non riconosciuto, Loomio trattiene l'email e avvisa gli amministratori del gruppo. Un amministratore del gruppo può approvare l'email e aggiungere l'indirizzo come alias per quel membro, oppure rifiutare le email successive provenienti da quell'indirizzo.

Una volta aggiunto un alias, le email successive provenienti da quell'indirizzo avviano immediatamente nuove conversazioni.

![Pulsanti per approvare o rifiutare un'email non riconosciuta](email_unreleased_emails.png)
