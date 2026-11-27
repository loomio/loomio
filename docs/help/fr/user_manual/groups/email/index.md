---
title: Adresse e-mail
source_revision: 95ce9afd64c99656f67e05a09fa9fc8a77af51d7
source_file: docs/help/en/user_manual/groups/email/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-11-26'
sections:
  introduction: 36b06c5b4604ac74
  preventing-unauthorized-emails: f4b8d2eaf0d79f01
generated:
  introduction: bd3e453aa2f7f702
  preventing-unauthorized-emails: d04817852f623353
title_source: f2488fd4ef4adbc6
title_generated: 8f9a920a57efeddf
---

<!-- translation-section: introduction -->

# Envoyez un e-mail pour créer un fil dans votre groupe

Chaque groupe Loomio dispose de sa propre adresse e-mail. Vous pouvez envoyer ou transférer un e-mail à cette adresse pour créer un nouveau fil dans le groupe.

Vous pouvez consulter l’adresse e-mail du groupe dans **Paramètres** sur la page du groupe :

![Emplacement de l’adresse e-mail dans Paramètres sur la page du groupe](email_email_button.png)

Lorsque vous envoyez un e-mail à cette adresse, Loomio crée un nouveau fil. L’objet de l’e-mail devient le titre du fil, le corps de l’e-mail devient sa description et les fichiers joints sont ajoutés au fil.

Loomio utilise l’adresse de l’expéditeur de l’e-mail (champ « De ») pour identifier le membre du groupe correspondant et le définir comme auteur du fil.

<!-- translation-section: preventing-unauthorized-emails -->

## Empêcher les e-mails non autorisés

Pour empêcher les personnes qui ne sont pas membres du groupe de créer des fils, Loomio exige que l’adresse de l’expéditeur d’un e-mail reçu (champ « De ») corresponde à l’adresse e-mail d’un membre du groupe.

Si un membre envoie un e-mail depuis une adresse non reconnue, Loomio met l’e-mail en attente et avertit les administrateurs du groupe. Un administrateur du groupe peut approuver l’e-mail et ajouter cette adresse comme alias pour ce membre, ou rejeter les futurs e-mails provenant de cette adresse.

Une fois l’alias ajouté, les futurs e-mails provenant de cette adresse créent immédiatement des fils.

![Boutons d’approbation et de rejet d’un e-mail provenant d’une adresse non reconnue](email_unreleased_emails.png)
