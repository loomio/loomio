---
title: Recueillir des contributions privées
source_revision: 7a01b0fd7d7df0c4bca327a916b01b12e62b967f
source_file: docs/user_manual/discussions/private_submissions/index.md
translated:
  provider: codex/gpt-6-sol
  'on': '2026-09-29'
sections:
  introduction: 1d263d407af586d9
  enable-private-submissions: 3520fbea1fb1267f
  set-up-a-private-submission-process: e9e30dd30ab9d468
  make-a-submission: ac6611a046f0bf9f
  review-submissions: 7014e6ac14301129
generated:
  introduction: 6343643b3fc63d91
  enable-private-submissions: 4ac958032f5f5ca9
  set-up-a-private-submission-process: 8513a61575009e51
  make-a-submission: a468e73db051d58d
  review-submissions: 7b11be7f8c6cd1e3
title_source: e82ab76916d594f4
title_generated: 0774715462c60afb
---

<!-- translation-section: introduction -->

# Recueillir des contributions privées

Utilisez un groupe Fermé pour recueillir des contributions privées de personnes qui n’en sont pas membres. Chaque contribution devient une discussion distincte. Son auteur et l’équipe chargée de l’examiner peuvent y échanger des informations, poser des questions et consigner une décision. Les auteurs ne peuvent pas voir les autres discussions ou contributions privées du groupe.

Ce fonctionnement convient aux candidatures lorsque les informations sur les candidats ou la liste des personnes proposées doivent rester privées pendant la sélection. Une personne peut proposer sa propre candidature ou celle de quelqu’un d’autre à une élection, une nomination, un comité, un conseil ou un poste de représentation. Le comité de sélection examine chaque candidature dans une discussion distincte.

Vous pouvez aussi l’utiliser pour d’autres contributions qui ne doivent pas être publiques :

- Plaintes, signalements liés à la protection des personnes, préoccupations concernant la sécurité et rapports d’incident
- Recours et demandes de réexamen d’une décision concernant un cas individuel
- Demandes de médiation, de résolution de conflit ou de soutien personnel
- Candidatures contenant des informations personnelles, financières ou relatives aux critères d’admissibilité, comme des demandes d’aide financière ou de bourse
- Offres sous pli fermé ou réponses à un appel d’offres qui doivent rester privées pendant leur évaluation

Les contributions restent privées entre leurs auteurs, mais elles ne sont pas anonymes. Chaque auteur doit disposer d’un compte utilisateur, et tous les membres du groupe Fermé peuvent voir les contributions. Avant d’utiliser ce fonctionnement pour des informations sensibles, vérifiez qui fait partie du groupe chargé de les examiner.

<!-- translation-section: enable-private-submissions -->

## Activer les contributions privées

Vous devez être administrateur du groupe ou du sous-groupe dans lequel vous souhaitez recueillir les contributions.

1. Ouvrez le groupe.
2. Sélectionnez **Paramètres** (ou **Plus**, puis **Modifier les paramètres du groupe**).
3. Ouvrez **Permissions**.
4. Activez **Les non-membres peuvent démarrer des discussions**.
5. Enregistrez les paramètres du groupe.

![L’onglet Permissions des paramètres du groupe, avec l’option Les non-membres peuvent démarrer des discussions mise en évidence](non_members_can_start_discussions.png)

Cette option est disponible uniquement pour les groupes **Ouvert** et **Fermé**. Elle est masquée pour les groupes **Secret**. Si vous ne la voyez pas, ouvrez **Confidentialité** dans les paramètres du groupe et réglez **Confidentialité du groupe** sur **Fermé** (recommandé pour les contributions privées) ou **Ouvert**, puis revenez à **Permissions**.

Activer cette permission ne rend pas publiques les discussions du groupe. Une personne qui n’est pas membre peut lancer une discussion et y accéder en tant qu’invitée, mais elle ne peut pas voir les autres discussions privées du groupe.

<!-- translation-section: set-up-a-private-submission-process -->

## Mettre en place un processus de contribution privée

1. Créez un sous-groupe consacré aux contributions et réglez sa confidentialité sur **Fermé**. Le sous-groupe permet de séparer les contributions des autres activités du groupe parent.
2. Ajoutez au sous-groupe les membres du comité de sélection ou les autres personnes chargées d’examiner les contributions. Chaque membre du sous-groupe peut voir toutes les contributions. N’ajoutez donc que les personnes qui doivent y avoir accès.
3. Créez un [modèle de discussion](/en/user_manual/discussions/templates) dans le sous-groupe. Précisez les questions auxquelles les auteurs doivent répondre et les informations à fournir. Vous pouvez créer différents modèles de discussion selon le type de contribution.
4. Si les auteurs ne doivent pas pouvoir demander à rejoindre le sous-groupe, réglez l’adhésion sur **Sur invitation uniquement**.
5. [Activez les contributions privées](#enable-private-submissions) dans les permissions du sous-groupe.
6. Testez le processus avec un compte qui n’est pas membre du sous-groupe.
7. Partagez la page du sous-groupe avec les personnes susceptibles de contribuer. Elles doivent se connecter à leur compte utilisateur avant de déposer une contribution.

<!-- translation-section: make-a-submission -->

## Déposer une contribution

La personne qui souhaite contribuer ouvre le sous-groupe et sélectionne **Lancer une discussion**. Loomio affiche les modèles de discussion disponibles dans le sous-groupe. Elle choisit le modèle approprié, répond aux questions et lance la discussion.

La discussion appartient au sous-groupe, mais son auteur n’en devient pas membre. Loomio l’ajoute comme invité de son fil de discussion. Il peut ainsi consulter la discussion et y participer avec le comité ou l’équipe chargée de l’examen. Il ne peut pas voir les autres discussions ou contributions privées du sous-groupe.

<!-- translation-section: review-submissions -->

## Examiner les contributions

Les membres du sous-groupe peuvent voir toutes les discussions liées aux contributions. Ils peuvent poser des questions complémentaires et utiliser les commentaires, les sondages ou d’autres outils de discussion pour mener leur examen.

Si une autre personne doit fournir des informations, un membre du sous-groupe qui en a la permission peut l’inviter à la discussion. Par exemple, lorsqu’une personne propose la candidature de quelqu’un d’autre, le sous-groupe peut inviter la personne proposée à rejoindre le fil si sa participation est nécessaire. La personne invitée devient une invitée de la discussion, sans accéder aux autres discussions privées du sous-groupe.

Chaque auteur peut voir sa propre contribution, mais pas les autres discussions ou contributions privées du sous-groupe. Désactivez **Les non-membres peuvent démarrer des discussions** lorsque la période de dépôt prend fin. Les discussions existantes et l’accès des invités restent inchangés.
