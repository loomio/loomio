---
title: E-Mail-Adresse
source_revision: ad97f553685def918a7d6e47ac5b66773de2dba8
source_file: docs/help/en/user_manual/groups/email/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-11-22'
sections:
  introduction: '03039e0babf5a9b6'
  preventing-unauthorized-emails: f4b8d2eaf0d79f01
generated:
  introduction: 723e6f3a1a745887
  preventing-unauthorized-emails: 9a7418111d0446f1
title_source: f2488fd4ef4adbc6
title_generated: c2f9765ad5cefe3a
---

<!-- translation-section: introduction -->

# Sende eine E-Mail, um einen Thread in deiner Gruppe zu starten

Jede Loomio-Gruppe hat eine eigene E-Mail-Adresse. Du kannst eine E-Mail an diese Adresse senden oder weiterleiten, um einen neuen Thread in der Gruppe zu starten.

Du findest die E-Mail-Adresse der Gruppe auf der Gruppenseite:

![Position der E-Mail-Adresse auf der Gruppenseite](email_email_button.png)

Wenn du eine E-Mail an diese Adresse sendest, erstellt Loomio einen neuen Thread. Der Betreff der E-Mail wird zum Titel des Threads, der Text wird zur Beschreibung des Threads und alle angehängten Dateien werden dem Thread hinzugefügt.

Anhand der Absenderadresse der E-Mail ordnet Loomio die absendende Person einem Gruppenmitglied zu und legt dieses als verfassendes Mitglied des Threads fest.

<!-- translation-section: preventing-unauthorized-emails -->

## Unberechtigte E-Mails verhindern

Damit nur Gruppenmitglieder Threads per E-Mail starten können, muss die Absenderadresse einer eingehenden E-Mail mit der E-Mail-Adresse eines Gruppenmitglieds übereinstimmen.

Wenn ein Mitglied eine E-Mail von einer unbekannten Adresse sendet, hält Loomio die E-Mail zurück und benachrichtigt die Gruppen-Admins. Ein Gruppen-Admin kann die E-Mail genehmigen und die Adresse als Alias für dieses Mitglied hinzufügen oder weitere E-Mails von dieser Adresse ablehnen.

Sobald ein Alias hinzugefügt wurde, starten künftige E-Mails von dieser Adresse sofort neue Threads.

![Schaltflächen zum Genehmigen und Ablehnen einer E-Mail von einer unbekannten Adresse](email_unreleased_emails.png)
