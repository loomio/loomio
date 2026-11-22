---
title: Recueillir des contributions privées
source_revision: ad97f553685def918a7d6e47ac5b66773de2dba8
source_file: docs/help/en/user_manual/discussions/private_submissions/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-11-22'
sections:
  introduction: 4ec7d13335b07a50
  enable-private-submissions: dd5106b8411a85ba
  set-up-a-private-submission-process: cb0361b8044af3e3
  make-a-submission: c04bd9ef30f8db97
  review-submissions: 267be9e3c705c196
generated:
  introduction: 96cdacba0e5379e6
  enable-private-submissions: 2f66625c53edf078
  set-up-a-private-submission-process: 2185b80b02592e83
  make-a-submission: 9a45272f4fcdfc44
  review-submissions: f6d7dd2573cc5148
title_source: e82ab76916d594f4
title_generated: 0774715462c60afb
---

<!-- translation-section: introduction -->

# Recueillir des contributions privées

Utilisez un groupe fermé pour recueillir des contributions privées de personnes extérieures au groupe. Chaque contribution devient une discussion distincte dans laquelle la personne qui l’a soumise et l’équipe chargée de l’examen peuvent échanger des informations, poser des questions et consigner une décision. Les personnes qui soumettent une contribution ne peuvent pas voir les autres discussions ou contributions privées du groupe.

Ce fonctionnement convient aux candidatures lorsque les informations sur les candidats ou leur liste doivent rester privées pendant la sélection. Une personne peut proposer sa propre candidature ou celle d’une autre personne pour une élection, un comité ou un poste au conseil d’administration, tandis que le comité de sélection examine chaque candidature dans un fil distinct.

Les autres usages courants comprennent :

- Plaintes, signalements concernant la protection des personnes, préoccupations liées à la sécurité et rapports d’incident
- Recours et demandes de réexamen d’une décision concernant un cas individuel
- Demandes de médiation, de résolution de conflits ou de soutien personnel
- Demandes contenant des informations personnelles, financières ou relatives aux critères d’admissibilité, comme des aides financières en cas de difficultés ou des bourses d’études
- Offres sous pli fermé ou réponses à des appels d’offres qui doivent rester privées pendant leur évaluation

Ce processus préserve la confidentialité entre les personnes qui soumettent une contribution, mais il n’est pas anonyme. Ces personnes doivent disposer d’un compte utilisateur, et chaque membre du groupe fermé peut voir toutes les contributions. Vérifiez qui fait partie du groupe avant de l’utiliser pour des informations sensibles.

<!-- translation-section: enable-private-submissions -->

## Activer les contributions privées

Vous devez être administrateur du groupe ou du sous-groupe dans lequel vous souhaitez recueillir des contributions.

1. Ouvrez le groupe.
2. Sélectionnez **Paramètres** (ou **Plus**, puis **Modifier les paramètres du groupe**).
3. Ouvrez **Permissions**.
4. Activez **Les non-membres peuvent démarrer des discussions**.
5. Enregistrez les paramètres du groupe.

![L’onglet Permissions dans les paramètres du groupe, avec l’option Les non-membres peuvent démarrer des discussions mise en évidence](non_members_can_start_discussions.png)

Cette option apparaît uniquement pour les groupes **Ouvert** et **Fermé**, pas pour les groupes **Secret**. Si vous ne la voyez pas, ouvrez **Confidentialité** dans les paramètres du groupe, réglez **Confidentialité du groupe** sur **Fermé** (recommandé pour les contributions privées) ou **Ouvert**, puis revenez à **Permissions**.

L’activation de cette permission ne rend pas les discussions du groupe publiques. Un non-membre peut lancer une discussion et accéder à ce fil en tant qu’invité, mais ne peut pas voir les autres discussions privées du groupe.

<!-- translation-section: set-up-a-private-submission-process -->

## Mettre en place un processus de contributions privées

1. Créez un sous-groupe dédié aux contributions et réglez sa confidentialité sur **Fermé**. Un sous-groupe permet de séparer les contributions des autres activités du groupe parent.
2. Ajoutez l’équipe chargée de l’examen ou le comité de sélection comme membres du sous-groupe. Chaque membre du sous-groupe peut voir toutes les contributions ; ajoutez donc uniquement les personnes qui ont besoin de cet accès.
3. Créez un ou plusieurs [modèles de discussion](/en/user_manual/discussions/templates) dans le sous-groupe avec les questions et les informations que les personnes qui soumettent une contribution doivent fournir.
4. Réglez l’adhésion sur **Sur invitation uniquement** si les personnes qui soumettent une contribution ne doivent pas demander à rejoindre le sous-groupe.
5. [Activez les contributions privées](#enable-private-submissions) dans les permissions du sous-groupe.
6. Testez le processus avec un compte qui n’est pas membre du sous-groupe.
7. Partagez la page du sous-groupe avec les personnes qui souhaitent soumettre une contribution. Elles doivent se connecter à un compte utilisateur avant de soumettre une contribution.

<!-- translation-section: make-a-submission -->

## Soumettre une contribution

La personne qui souhaite soumettre une contribution ouvre le sous-groupe et sélectionne **Lancer une discussion**. Loomio affiche les modèles de discussion du sous-groupe. La personne choisit le modèle approprié, répond aux questions et lance la discussion.

La discussion appartient au sous-groupe, et Loomio ajoute la personne qui l’a lancée en tant qu’invité à ce fil, sans qu’elle devienne membre du sous-groupe. Elle peut participer à son propre fil avec l’équipe chargée de l’examen, mais ne peut pas voir les autres discussions ou contributions privées du sous-groupe.

<!-- translation-section: review-submissions -->

## Examiner les contributions

Les membres du sous-groupe peuvent voir tous les fils correspondant aux contributions du sous-groupe. Ils peuvent poser des questions complémentaires et utiliser des commentaires, des sondages ou d’autres outils pour mener leur examen.

Si une autre personne doit donner son avis, un membre du sous-groupe disposant de la permission nécessaire peut l’inviter à ce fil. Par exemple, après qu’une personne a proposé une candidature, le comité peut inviter la personne candidate au fil. La personne invitée rejoint le fil en tant qu’invité, sans avoir accès aux autres discussions privées du sous-groupe.

Lorsque la période de contribution se termine, désactivez **Les non-membres peuvent démarrer des discussions**. Les fils de contribution existants et les accès des invités restent inchangés.
