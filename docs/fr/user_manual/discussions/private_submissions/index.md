---
title: Recueillir des contributions privées
source_revision: c6076258c3438c0dd6dc8fbf1fc0b0df47c0aeb5
source_file: docs/en/user_manual/discussions/private_submissions/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-01'
sections:
  introduction: 1d263d407af586d9
  enable-private-submissions: 3520fbea1fb1267f
  set-up-a-private-submission-process: e9e30dd30ab9d468
  make-a-submission: ac6611a046f0bf9f
  review-submissions: 7014e6ac14301129
generated:
  introduction: 3077a82524ff3f08
  enable-private-submissions: e5c727ba2f88eb86
  set-up-a-private-submission-process: 7bc4f92d94edfe4e
  make-a-submission: 864675be4325611c
  review-submissions: a581266d3576f62b
title_source: e82ab76916d594f4
title_generated: 0774715462c60afb
---

<!-- translation-section: introduction -->

# Recueillir des contributions privées

Utilisez un groupe fermé pour recueillir des contributions privées de personnes qui ne sont pas membres du groupe. Chaque contribution devient une discussion distincte dans laquelle la personne qui l’a soumise et l’équipe chargée de l’examen peuvent échanger des informations, poser des questions et consigner une décision. Les personnes qui soumettent une contribution ne peuvent pas voir les autres discussions ou contributions privées du groupe.

Les candidatures constituent un cas d’usage lorsque les informations sur les candidats ou leur liste doivent rester privées pendant la sélection. Une personne peut proposer sa propre candidature ou celle d’une autre personne pour une élection, une nomination, un comité, un conseil d’administration ou un rôle de représentation, tandis qu’un comité de sélection examine chaque candidature dans une discussion distincte.

Ce fonctionnement convient aussi aux situations suivantes, dans lesquelles les contributions doivent rester privées :

- Plaintes, signalements concernant la protection des personnes, préoccupations liées à la sécurité et rapports d’incident
- Recours et demandes de réexamen d’une décision concernant un cas individuel
- Demandes de médiation, de résolution de conflits ou de soutien personnel
- Demandes contenant des informations personnelles, financières ou relatives aux critères d’admissibilité, comme des aides financières en cas de difficultés ou des bourses d’études
- Offres sous pli fermé ou réponses à des appels d’offres qui doivent rester privées pendant leur évaluation

Ce processus préserve la confidentialité entre les personnes qui soumettent une contribution, mais il n’est pas anonyme. Ces personnes doivent disposer d’un compte utilisateur, et chaque membre du groupe fermé peut voir les contributions. Vérifiez qui fait partie du groupe chargé de l’examen avant de l’utiliser pour des informations sensibles.

<!-- translation-section: enable-private-submissions -->

## Activer les contributions privées

Vous devez être administrateur du groupe ou du sous-groupe dans lequel vous souhaitez recueillir des contributions.

1. Ouvrez le groupe.
2. Sélectionnez **Paramètres** (ou **Plus**, puis **Modifier les paramètres du groupe**).
3. Ouvrez **Permissions**.
4. Activez **Les non-membres peuvent démarrer des discussions**.
5. Enregistrez les paramètres du groupe.

![L’onglet Permissions dans les paramètres du groupe, avec l’option Les non-membres peuvent démarrer des discussions mise en évidence](non_members_can_start_discussions.png)

Cette option est disponible uniquement pour les groupes **Ouvert** et **Fermé**. Elle est masquée pour les groupes **Secret**. Si vous ne la voyez pas, ouvrez **Confidentialité** dans les paramètres du groupe et réglez **Confidentialité du groupe** sur **Fermé** (recommandé pour les contributions privées) ou **Ouvert**, puis revenez à **Permissions**.

L’activation de cette permission ne rend pas les discussions du groupe publiques. Un non-membre peut lancer une nouvelle discussion et y accéder en tant qu’invité, mais ne peut pas voir les autres discussions privées du groupe.

<!-- translation-section: set-up-a-private-submission-process -->

## Mettre en place un processus de contributions privées

1. Créez un sous-groupe dédié au processus de contribution et réglez sa confidentialité sur **Fermé**. Un sous-groupe permet de séparer les contributions des autres activités du groupe parent.
2. Ajoutez le comité de sélection ou les autres personnes chargées d’examiner les contributions comme membres du sous-groupe. Chaque membre du sous-groupe peut voir toutes les contributions ; ajoutez donc uniquement les personnes qui doivent disposer de cet accès.
3. Créez un [modèle de discussion](/en/user_manual/discussions/templates) dans le sous-groupe. Incluez les questions et les informations que les personnes doivent fournir. Vous pouvez créer différents modèles de discussion pour différents types de contributions.
4. Si les personnes qui soumettent une contribution ne doivent pas demander à rejoindre le sous-groupe, réglez l’adhésion sur **Sur invitation uniquement**.
5. [Activez les contributions privées](#enable-private-submissions) dans les permissions du sous-groupe.
6. Testez le processus avec un compte qui n’est pas membre du sous-groupe.
7. Partagez la page du sous-groupe avec les personnes susceptibles de soumettre une contribution. Elles doivent se connecter à leur compte utilisateur avant de soumettre une contribution.

<!-- translation-section: make-a-submission -->

## Soumettre une contribution

La personne qui souhaite soumettre une contribution ouvre le sous-groupe et sélectionne **Lancer une discussion**. Loomio affiche les modèles de discussion disponibles dans le sous-groupe. La personne sélectionne le modèle de discussion approprié, répond aux questions et lance la discussion.

La discussion appartient au sous-groupe, mais la personne qui l’a lancée ne devient pas membre du sous-groupe. Loomio l’ajoute en tant qu’invité à son fil de discussion, ce qui lui permet de consulter la discussion et d’y participer avec le comité ou l’équipe chargée de l’examen. Elle ne peut pas voir les autres discussions ou contributions privées du sous-groupe.

<!-- translation-section: review-submissions -->

## Examiner les contributions

Les membres du sous-groupe peuvent voir toutes les discussions correspondant aux contributions du sous-groupe. Ils peuvent poser des questions complémentaires et utiliser des commentaires, des sondages ou d’autres outils de discussion pour mener leur examen.

Si une autre personne doit fournir des informations, un membre du sous-groupe disposant de la permission nécessaire peut l’inviter à la discussion correspondant à la contribution. Par exemple, lorsqu’une personne propose une candidature, le sous-groupe peut inviter la personne candidate au fil si sa participation est nécessaire. La personne invitée rejoint le fil en tant qu’invité, sans avoir accès aux autres discussions privées du sous-groupe.

Chaque personne qui soumet une contribution peut voir sa propre contribution, mais ne peut pas voir les autres discussions ou contributions privées du sous-groupe. Désactivez **Les non-membres peuvent démarrer des discussions** lorsque la période de contribution se termine. Les discussions existantes et les accès des invités restent inchangés.
