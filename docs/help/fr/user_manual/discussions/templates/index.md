---
title: Modèles de discussion
source_revision: c6076258c3438c0dd6dc8fbf1fc0b0df47c0aeb5
source_file: docs/en/user_manual/discussions/templates/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-01'
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
  introduction: 187a2e572ccfb339
  how-templates-are-used: db5b15b1e79e3885
  choose-who-is-notified-by-default: 124aa359d558dc1b
  template-settings: 7ab593b2e571177e
  example-bottle-trial-review: '07495be8434faba4'
  create-a-template: 27c009c5f4013f5d
  manage-the-template-list: 5171165d289de886
  share-templates-between-groups: 159a36eedbce353a
  let-members-create-templates: a0ad468c2b8b3361
  templates-for-non-members: 7fef1b42802231ff
  related: c11ae1cbf27daade
title_source: 5ac608aa42806d13
title_generated: 0a2818116b3c746a
---

<!-- translation-section: introduction -->

# Modèles de discussion

Les modèles de discussion aident votre groupe à lancer les discussions de la même manière à chaque fois. Un modèle peut fournir un titre, un contexte, des tags et des instructions pour la personne qui lance la discussion. Il définit aussi des paramètres par défaut, comme les personnes à notifier et les sondages à suggérer.

Toute nouvelle discussion dans un groupe commence à partir d’un modèle. Lorsqu’une personne sélectionne **Lancer une discussion**, Loomio affiche les modèles du groupe. Même **Modèle vierge** est un modèle : votre groupe peut donc aussi modifier ses paramètres par défaut.

Les modèles conviennent aux processus que votre groupe répète, comme les bilans de projet, les processus de sollicitation d’avis, la préparation de réunions, les décisions de financement ou l’approbation de documents. La personne qui lance la discussion peut toujours tout modifier avant de la lancer.

<!-- translation-section: how-templates-are-used -->

## Utilisation des modèles

1. Un membre sélectionne **Lancer une discussion** sur la page du groupe.
2. Loomio affiche la liste des modèles visibles du groupe. Chaque modèle présente son titre et son sous-titre.
3. Le membre sélectionne un modèle. Loomio ouvre le formulaire de nouvelle discussion, prérempli à partir du modèle.
4. L’aide du modèle apparaît en haut du formulaire pour guider le membre.
5. Le membre modifie le titre, le contexte, les tags et la liste des personnes invitées, puis sélectionne **Lancer une discussion**.

![](list.png)

La modification d’un modèle ne concerne que les discussions lancées après cette modification. Les discussions déjà lancées à partir de ce modèle conservent leur contenu et leurs paramètres.

<!-- translation-section: choose-who-is-notified-by-default -->

## Choisissez qui reçoit une notification par défaut

Le paramètre **Inviter** détermine qui le formulaire de nouvelle discussion invite par défaut. Il propose deux options :

- **Tout le monde dans le groupe** : le groupe apparaît dans le champ **Inviter** du formulaire de discussion, et chaque membre reçoit une notification lorsque la discussion est lancée.
- **Aucun** : le champ **Inviter** est initialement vide. Personne ne reçoit de notification à moins que l’auteur ajoute des personnes.

Les modèles intégrés à Loomio, y compris **Modèle vierge**, utilisent **Tout le monde dans le groupe**. Si votre groupe ne souhaite pas que chaque nouvelle discussion envoie une notification à tous les membres, modifiez les modèles qu’il utilise et réglez **Inviter** sur **Aucun**.

![](use.png)

L’auteur peut toujours modifier la liste des personnes invitées avant de lancer la discussion. Il peut retirer le groupe pour ne notifier personne, ou ajouter des personnes précises à la place. Ce paramètre concerne uniquement les notifications. Les membres du groupe peuvent toujours trouver et lire la discussion dans le groupe, quelle que soit l’option choisie.

Le groupe n’est ajouté à la liste des personnes invitées que si l’auteur a la permission de notifier tout le groupe. Les administrateurs peuvent toujours le faire. Les membres peuvent le faire lorsque **Les membres peuvent notifier n'importe qui dans le groupe** est activé dans les permissions du groupe.

<!-- translation-section: template-settings -->

## Paramètres du modèle

Les administrateurs du groupe peuvent modifier un modèle depuis le menu d’actions situé à côté de celui-ci dans la liste des modèles. Le formulaire comprend les paramètres suivants :

![](form.png)

- **Titre du modèle** : le nom court affiché dans la liste des modèles.
- **Sous-titre du modèle** : une ligne expliquant quand utiliser le modèle.
- **Aide sur les modèles** : les instructions affichées en haut du formulaire de nouvelle discussion. Utilisez-les pour expliquer le processus et fournir des liens vers des ressources. Elles ne font pas partie de la discussion.
- **Groupe** : indique si le modèle lance une discussion dans le groupe ou une discussion directe. Une discussion directe n’est visible que par les personnes qui y sont invitées.
- **titre par défaut** : un titre prérempli pour chaque nouvelle discussion. L’auteur peut le modifier.
- **Exemple de titre** : un exemple affiché dans un champ de titre vide. Utilisez-le lorsqu’un titre par défaut ne conviendrait pas à toutes les discussions.
- **Mots-clés** : les tags appliqués à chaque nouvelle discussion. L’auteur peut les retirer.
- **Contexte** : le texte initial de la discussion. Utilisez des titres, des questions ou des liens pour guider ce que les personnes écrivent.
- **Inviter** : indique si tout le monde dans le groupe est invité par défaut. Voir [Choisissez qui reçoit une notification par défaut](#choose-who-is-notified-by-default).
- **Modèles de sondage** : les sondages suggérés pour ce processus. Ils figurent dans le formulaire de nouvelle discussion. Ils apparaissent aussi en premier lorsqu’une personne lance un sondage dans la discussion. Ils ne sont pas lancés automatiquement.
- **Autoriser les sondages simultanés** : indique si plusieurs sondages peuvent être ouverts en même temps dans la discussion.
- **Limite de longueur des commentaires** : une longueur maximale facultative pour les commentaires.

Utilisez un titre par défaut uniquement s’il reste pertinent pour chaque discussion. Sinon, rédigez un exemple de titre qui invite l’auteur à préciser le bilan, la période, le document ou la décision concernés.

<!-- translation-section: example-bottle-trial-review -->

## Exemple : bilan de l’essai de bouteilles consignées

Oatmilk Cooperative fait le bilan de son essai de bouteilles consignées après chaque cycle. Son modèle s’intitule « Bilan de l’essai de bouteilles consignées » et comporte un titre par défaut. Il ajoute le tag « Essai de bouteilles consignées ». Son contexte demande aux membres de lire le rapport hebdomadaire et d’examiner les taux de retour, les relevés de lavage, les retours des cafés et les coûts de transport. Il recommande une prise de température suivie d’un sondage de Consentement.

Ce processus se prête à un modèle, car l’objectif et les éléments à examiner restent les mêmes à chaque cycle. Seules les observations et les décisions changent.

<!-- translation-section: create-a-template -->

## Créez un modèle

Les administrateurs du groupe peuvent sélectionner **Nouveau modèle** dans la liste des modèles. Choisissez un exemple dans la galerie de Loomio ou commencez avec un modèle vierge, puis adaptez-le et enregistrez-le.

Vous pouvez rechercher ou filtrer les modèles de la galerie. Un exemple n’est ajouté à votre groupe que lorsque vous l’enregistrez.

<!-- translation-section: manage-the-template-list -->

## Gérez la liste des modèles

Lors de la création d’un groupe, Loomio ajoute un ensemble de modèles adaptés au type de groupe. Seuls **Modèle vierge** et **Discussion pratique** sont visibles au départ. Les autres sont cachés, et les administrateurs peuvent les rendre visibles.

Les administrateurs du groupe peuvent utiliser le menu d’actions situé à côté d’un modèle pour :

- modifier son contenu et ses paramètres ;
- le cacher dans la liste des modèles ;
- le rendre visible depuis **Modèles cachés** ;
- réorganiser l’ordre des modèles visibles ;
- l’exporter sous forme de fichier JSON ; ou
- le supprimer.

Cacher un modèle permet de le conserver pour une utilisation ultérieure. Supprimer un modèle ne supprime pas les discussions lancées à partir de celui-ci.

<!-- translation-section: share-templates-between-groups -->

## Partagez des modèles entre groupes

Sélectionnez **Exporter au format JSON** dans le menu d’actions d’un modèle pour le télécharger sous forme de fichier. Pour l’utiliser dans un autre groupe, sélectionnez **Nouveau modèle**, puis **Importer du JSON**. Le formulaire s’ouvre avec le contenu importé pour que vous puissiez le vérifier avant de l’enregistrer.

Les liens vers les modèles de sondage personnalisés ne sont pas inclus dans le fichier. Exportez et importez ces modèles de sondage séparément.

<!-- translation-section: let-members-create-templates -->

## Autorisez les membres à créer des modèles

Par défaut, seuls les administrateurs du groupe peuvent créer et modifier des modèles. Un administrateur peut activer **Les membres peuvent créer des modèles** dans **Paramètres de groupe** → **Permissions**.

Lorsque cette permission est activée, les membres peuvent créer des modèles de discussion et de sondage, et modifier les modèles qu’ils ont créés. Les administrateurs peuvent modifier tous les modèles du groupe. Le modèle d’un membre apparaît dans la liste des modèles du groupe dès son enregistrement : convenez donc de règles de nommage et de vérification avant d’activer cette permission.

<!-- translation-section: templates-for-non-members -->

## Modèles pour les non-membres

Si **Les non-membres peuvent démarrer des discussions** est activé, les personnes extérieures au groupe choisissent dans la même liste de modèles. Leur formulaire de discussion n’invite jamais le groupe par défaut. Voir [Recueillir des contributions privées](/en/user_manual/discussions/private_submissions).

<!-- translation-section: related -->

## Voir aussi

- [Modèles de sondage](/en/user_manual/polls/poll_templates)
