---
title: Modèles de discussion
source_revision: 7a01b0fd7d7df0c4bca327a916b01b12e62b967f
source_file: docs/user_manual/discussions/templates/index.md
translated:
  provider: codex/gpt-6-sol
  'on': '2026-09-29'
sections:
  introduction: 9b2b30212a057b4b
  how-templates-are-used: 7d5681170fe9911e
  choose-who-is-notified-by-default: e9fe4c939442f514
  template-settings: 2e71090b3d149213
  example-bottle-trial-review: 20009020c0b68fdf
  create-a-template: 223eee427ebb52bb
  manage-the-template-list: 9a4957687be2b34d
  share-templates-between-groups: 2bff30bad2a0eb4a
  let-members-create-templates: 0cfd990ff48a1a09
  templates-for-non-members: ebaf610bf85e81a9
  related: 6f4cc2ccf8e709d3
generated:
  introduction: 3291ea26a63e4808
  how-templates-are-used: 07dadea6498b8eaf
  choose-who-is-notified-by-default: 4b38d45e4004c4d8
  template-settings: d82fd789591c979a
  example-bottle-trial-review: b2b0500d480e14c3
  create-a-template: 31f70f2bc1c21212
  manage-the-template-list: e61bc2acf444b4ef
  share-templates-between-groups: 6ab71b2921073e99
  let-members-create-templates: dd602b2192490900
  templates-for-non-members: 82c71336f39c683e
  related: c11ae1cbf27daade
title_source: 5ac608aa42806d13
title_generated: 0a2818116b3c746a
---

<!-- translation-section: introduction -->

# Modèles de discussion

Les modèles de discussion aident votre groupe à lancer ses discussions selon un même processus. Un modèle peut fournir un titre, un contexte, des mots-clés et des instructions pour la personne qui lance la discussion. Il définit aussi des paramètres par défaut, comme la notification de tout le groupe et les sondages à suggérer.

Chaque nouvelle discussion dans un groupe part d’un modèle. Lorsque quelqu’un sélectionne **Lancer une discussion**, Loomio affiche les modèles du groupe. **Modèle vierge** est également un modèle : votre groupe peut donc modifier ses paramètres par défaut.

Les modèles conviennent aux processus que votre groupe répète, comme les bilans de projet, les consultations, la préparation de réunions, les décisions de financement ou l’approbation de documents. La personne qui lance la discussion peut encore tout modifier avant de la créer.

<!-- translation-section: how-templates-are-used -->

## Utilisation des modèles

1. Un membre sélectionne **Lancer une discussion** sur la page du groupe.
2. Loomio affiche les modèles visibles du groupe. Chacun présente son titre et son sous-titre.
3. Le membre sélectionne un modèle. Loomio ouvre le formulaire de nouvelle discussion, prérempli à partir du modèle.
4. L’aide du modèle apparaît en haut du formulaire pour guider le membre.
5. Le membre modifie le titre, le contexte, les mots-clés et la liste des personnes invitées, puis sélectionne **Lancer une discussion**.

![](list.png)

La modification d’un modèle ne concerne que les discussions lancées après ce changement. Les discussions déjà créées à partir de ce modèle conservent leur contenu et leurs paramètres.

<!-- translation-section: choose-who-is-notified-by-default -->

## Choisir qui reçoit une notification par défaut

Le paramètre **Inviter** détermine qui est invité par défaut dans le formulaire de nouvelle discussion. Deux options sont proposées :

- **Tout le monde dans le groupe** : le groupe apparaît dans le champ **Inviter** du formulaire de discussion, et chaque membre reçoit une notification au lancement de la discussion.
- **Aucun** : le champ **Inviter** est vide au départ. Personne ne reçoit de notification, sauf si l’auteur ajoute des personnes.

Les modèles fournis par Loomio, dont **Modèle vierge**, utilisent **Tout le monde dans le groupe**. Si votre groupe ne souhaite pas notifier tous ses membres à chaque nouvelle discussion, modifiez les modèles qu’il utilise et réglez **Inviter** sur **Aucun**.

![](use.png)

L’auteur peut toujours modifier la liste des personnes invitées avant de lancer la discussion. Il peut retirer le groupe pour ne notifier personne, ou ajouter certaines personnes à la place. Ce paramètre concerne uniquement les notifications. Les membres du groupe peuvent toujours trouver et lire la discussion dans le groupe, quelle que soit l’option choisie.

Le groupe n’est ajouté à la liste des personnes invitées que si l’auteur a le droit de notifier tout le groupe. Les administrateurs ont toujours ce droit. Les membres l’ont lorsque **Les membres peuvent notifier n'importe qui dans le groupe** est activé dans les permissions du groupe.

<!-- translation-section: template-settings -->

## Paramètres du modèle

Les administrateurs du groupe peuvent modifier un modèle depuis le menu d’actions situé à côté de celui-ci dans la liste des modèles. Le formulaire comprend les paramètres suivants :

![](form.png)

- **Titre du modèle** : le nom court affiché dans la liste des modèles.
- **Sous-titre du modèle** : une ligne qui explique quand utiliser le modèle.
- **Aide sur les modèles** : les instructions affichées en haut du formulaire de nouvelle discussion. Utilisez-les pour expliquer le processus et fournir des liens vers des ressources. Elles ne font pas partie de la discussion.
- **Groupe** : indique si le modèle lance une discussion dans le groupe ou une discussion directe. Seules les personnes invitées peuvent voir une discussion directe.
- **titre par défaut** : un titre prérempli pour chaque nouvelle discussion. L’auteur peut le modifier.
- **Exemple de titre** : un exemple affiché lorsque le champ du titre est vide. Utilisez-le si un titre par défaut ne convient pas à toutes les discussions.
- **Mots-clés** : les mots-clés appliqués à chaque nouvelle discussion. L’auteur peut les retirer.
- **Contexte** : le texte initial de la discussion. Utilisez des titres, des questions ou des liens pour guider les contributions.
- **Inviter** : indique si tout le groupe est invité par défaut. Voir [Choisir qui reçoit une notification par défaut](#choose-who-is-notified-by-default).
- **Modèles de sondage** : les sondages suggérés pour ce processus. Ils figurent dans le formulaire de nouvelle discussion. Ils apparaissent aussi en premier lorsqu’une personne lance un sondage dans la discussion. Ils ne démarrent pas automatiquement.
- **Autoriser les sondages simultanés** : indique si plusieurs sondages peuvent être ouverts en même temps dans la discussion.
- **Limite de longueur des commentaires** : une longueur maximale facultative pour les commentaires.

N’utilisez un titre par défaut que s’il reste adapté à chaque discussion. Sinon, proposez un exemple qui invite l’auteur à nommer le bilan, la période, le document ou la décision concernés.

<!-- translation-section: example-bottle-trial-review -->

## Exemple : bilan d’un essai de bouteilles

La coopérative Oatmilk fait le bilan de son essai de bouteilles consignées après chaque cycle. Son modèle s’intitule « Bilan de l’essai de bouteilles » et comporte un titre par défaut. Il ajoute le mot-clé « Essai de bouteilles ». Son contexte demande aux membres de lire le rapport hebdomadaire et d’examiner les taux de retour, les registres de lavage, les retours des cafés et les coûts de transport. Il recommande une vérification de compréhension suivie d’un consentement.

Ce processus se prête à un modèle, car son objectif et les éléments à examiner restent les mêmes à chaque cycle. Seules les observations et les décisions changent.

<!-- translation-section: create-a-template -->

## Créer un modèle

Les administrateurs du groupe peuvent sélectionner **Nouveau modèle** dans la liste des modèles. Choisissez un exemple dans la galerie de Loomio ou partez d’un modèle vierge, puis adaptez-le et enregistrez-le.

Vous pouvez effectuer une recherche ou filtrer la galerie. Un exemple n’est ajouté à votre groupe qu’une fois enregistré.

<!-- translation-section: manage-the-template-list -->

## Gérer la liste des modèles

Lorsqu’un groupe est créé, Loomio ajoute un ensemble de modèles adaptés à son type. Seuls **Modèle vierge** et **Discussion pratique** sont visibles au départ. Les autres sont cachés, et les administrateurs peuvent les rendre visibles.

Les administrateurs du groupe peuvent utiliser le menu d’actions situé à côté d’un modèle pour :

- modifier son contenu et ses paramètres ;
- le cacher de la liste des modèles ;
- le rendre visible depuis **Modèles cachés** ;
- modifier l’ordre des modèles visibles ;
- l’exporter dans un fichier JSON ; ou
- le supprimer.

Un modèle caché reste disponible pour une utilisation ultérieure. La suppression d’un modèle ne supprime pas les discussions créées à partir de celui-ci.

<!-- translation-section: share-templates-between-groups -->

## Partager des modèles entre groupes

Sélectionnez **Exporter au format JSON** dans le menu d’actions d’un modèle pour le télécharger sous forme de fichier. Pour l’utiliser dans un autre groupe, sélectionnez **Nouveau modèle**, puis **Importer du JSON**. Le formulaire s’ouvre avec le contenu importé pour que vous puissiez le vérifier avant de l’enregistrer.

Les liens vers les modèles de sondage personnalisés ne sont pas inclus dans le fichier. Exportez et importez ces modèles de sondage séparément.

<!-- translation-section: let-members-create-templates -->

## Permettre aux membres de créer des modèles

Par défaut, seuls les administrateurs du groupe peuvent créer et modifier des modèles. Un administrateur peut activer **Les membres peuvent créer des modèles** dans **Paramètres de groupe** → **Permissions**.

Lorsque cette permission est activée, les membres peuvent créer des modèles de discussion et de sondage, puis modifier ceux qu’ils ont créés. Les administrateurs peuvent modifier tous les modèles du groupe. Dès qu’un membre enregistre son modèle, celui-ci apparaît dans la liste des modèles du groupe. Convenez donc de règles pour les noms et la vérification des modèles avant d’activer cette permission.

<!-- translation-section: templates-for-non-members -->

## Modèles pour les personnes qui ne sont pas membres

Si **Les non-membres peuvent démarrer des discussions** est activé, les personnes extérieures au groupe choisissent dans la même liste de modèles. Leur formulaire de discussion n’invite jamais le groupe par défaut. Voir [Recueillir des contributions privées](/en/user_manual/discussions/private_submissions).

<!-- translation-section: related -->

## Voir aussi

- [Modèles de sondage](/en/user_manual/polls/poll_templates)
