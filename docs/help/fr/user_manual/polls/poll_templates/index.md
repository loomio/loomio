---
title: Modèles de sondage
source_revision: ad97f553685def918a7d6e47ac5b66773de2dba8
source_file: docs/help/en/user_manual/polls/poll_templates/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-11-22'
sections:
  introduction: 227665c7b66356be
  who-can-manage-templates: 2f0ab3bdaf9d093a
  create-a-poll-template: 0fafc6275b6c9153
  template-title-subtitle-and-help: 5a3f6c78e32fb066
  voting-method: 3ad5838dfcb67da0
  example-title-details-and-tags: 0f0d84a8b9b6ecb2
  response-options: e6ef2fb08eb66840
  duration-and-settings: 9b3c78d3c0d4986a
  manage-the-template-list: a58617ec50baf468
  save-a-poll-as-a-template: 36dc7b5d410d0eea
  start-a-new-template: 4f14910d88b22de8
  configure-the-template: 5fdb36299dd771b8
  edit-a-default-template: 6f1e7050d20ed373
generated:
  introduction: b965f3cb88d065f9
  who-can-manage-templates: 8415575d22a226aa
  create-a-poll-template: 1334d2e3d3d73853
  template-title-subtitle-and-help: 344248e8b3992859
  voting-method: 0a2ab7a142743e7e
  example-title-details-and-tags: acd0018624924a32
  response-options: 994d6ba51364285d
  duration-and-settings: c99bb395ff56e6bb
  manage-the-template-list: 97d736f4ad9db7c3
  save-a-poll-as-a-template: 382da00f01cd87df
  start-a-new-template: 12253dceea1c3b74
  configure-the-template: d6c4f028dd1ca692
  edit-a-default-template: 8e612d7b6c8ef601
title_source: 114cca246e357304
title_generated: cd672e826498e8c7
---

<!-- translation-section: introduction -->

# Modèles de sondage

Les modèles de sondage sont des points de départ réutilisables qui s’affichent lorsqu’une personne sélectionne **Lancer un vote** ou **Nouveau sondage**. Un modèle associe une méthode de vote à des consignes, des options de réponse et des paramètres prédéfinis.

Utilisez cette page pour configurer les modèles disponibles dans un groupe ou en créer un pour votre propre processus. Pour choisir un modèle pour un vote particulier, consultez [Propositions](../proposals/) ou [Sondages](../proposal_types/). Pour faciliter un processus de décision complet, consultez [Prendre des décisions](/en/guides/making_decisions/).

Lorsque vous lancez un vote, sélectionnez l’onglet **Proposition** ou **Sondage** et choisissez un modèle disponible dans le groupe.

Le modèle fournit une introduction, un exemple de contenu, des options et des paramètres. Vérifiez et adaptez ces éléments à votre décision avant de lancer le vote. Modifier un nouveau vote ne change pas le modèle.

<!-- translation-section: create-a-poll-template -->

## Créer un modèle de sondage

<!-- translation-section: save-a-poll-as-a-template -->

### Enregistrer comme modèle

Pour réutiliser une proposition ou un sondage existant, ouvrez son menu d’actions et sélectionnez **Enregistrer comme modèle**.

![Une proposition avec son menu d’actions ouvert et l’option Enregistrer comme modèle mise en évidence](save_as_template.png)

Les dates du vote, les électeurs, les votes, les résultats et la conclusion du sondage ne sont pas enregistrés dans le modèle.

<!-- translation-section: start-a-new-template -->

### Créer un nouveau modèle

Ouvrez la liste des modèles et sélectionnez **Nouveau modèle**. Partez d’un exemple ou d’un modèle vierge, puis choisissez le groupe qui l’utilisera.

![](proposal_template_setting.png)

<!-- translation-section: edit-a-default-template -->

### Modifier un modèle par défaut

Pour adapter un modèle par défaut comme **Consentement**, ouvrez son menu d’actions et sélectionnez **Modifier le modèle**. Cette option est accessible aux administrateurs du groupe. L’enregistrement crée un modèle personnalisé pour votre groupe et masque la version par défaut dans sa liste de modèles.

![Le modèle par défaut Consentement avec l’action Modifier le modèle visible](edit_default_template.png)

<!-- translation-section: configure-the-template -->

## Paramètres du modèle

Donnez au modèle un nom et un sous-titre qui indiquent quand l’utiliser. Ajustez les autres champs pour que le modèle soit prêt à être réutilisé, puis sélectionnez **Enregistrer le modèle**. Le modèle apparaîtra alors lorsqu’une personne lancera une nouvelle proposition ou un nouveau sondage.

[![Le formulaire complet du modèle de processus de consentement pour un changement de politique](poll_template_new.png)](poll_template_new.png)

Pour les sondages autonomes, le paramètre **Seuls les administrateurs peuvent ajouter des pièces jointes** réserve l’ajout de nouveaux fichiers et d’images intégrées (y compris dans les réponses au sondage et les réponses aux commentaires) aux administrateurs du fil et du groupe. Les sondages dans un fil existant suivent le paramètre de pièces jointes de ce fil. La modification d’un modèle ne s’applique qu’aux futurs sondages.

<!-- translation-section: template-title-subtitle-and-help -->

### Titre, sous-titre et aide du modèle

Utilisez le titre et le sous-titre pour expliquer quand choisir le modèle. Ajoutez les consignes sur le processus, les règles de décision et les liens vers des ressources dans **Aide sur les modèles**.

<!-- translation-section: voting-method -->

### Méthode de vote

Choisissez ce que les participants doivent exprimer et comment le résultat doit être calculé :

- **Proposition** : répondre à un énoncé en utilisant des positions définies ;
- **Choisir** : sélectionner une ou plusieurs options ;
- **Score** : évaluer chaque option sur une échelle ;
- **Allouer** : répartir un nombre limité de points ;
- **Classer** : ranger les options par ordre de préférence ;
- **Sondage horaire** : indiquer les disponibilités ; et
- **STV** : classer les candidats dans une élection proportionnelle à plusieurs sièges.

Changer la méthode de vote modifie les champs et le calcul du résultat disponibles dans le modèle.

<!-- translation-section: example-title-details-and-tags -->

### Exemples de titre, de détails et de tags

Utilisez des consignes pour le titre et les détails de l’exemple lorsque chaque vote nécessite un contenu différent. Ajoutez des tags de catégorie par défaut uniquement s’ils s’appliquent à chaque utilisation du modèle.

<!-- translation-section: response-options -->

### Options de réponse

Les méthodes telles que Proposition et Choisir vous permettent de configurer les options de réponse. Sélectionnez l’icône de crayon à côté d’une option pour modifier :

- **Nom de l’option** : le libellé court de la réponse ;
- **Icône** : son repère visuel ;
- **Signification** : ce que le choix de l’option exprime ; et
- **Invite de raison** : la question affichée lorsqu’une personne explique son vote.

![](poll_type_edit_option.png)

Définissez les options pour que les participants puissent les distinguer sans avoir à deviner leur sens. Les significations doivent correspondre aux règles de décision que votre groupe utilise réellement.

<!-- translation-section: duration-and-settings -->

### Durée et paramètres

Définissez une durée par défaut adaptée à la plupart des utilisations du modèle. L’auteur peut modifier l’heure de clôture d’un vote particulier.

D’autres paramètres par défaut déterminent la visibilité des résultats, le vote anonyme, le [vote pondéré](../weighted_voting/), l’obligation de fournir une raison du vote, les rappels, le quorum et le fonctionnement propre à chaque méthode. Consultez [Paramètres des propositions et des sondages](../settings/) pour en savoir plus.

<!-- translation-section: manage-the-template-list -->

## Gérer les modèles

Utilisez le menu d’actions à côté d’un modèle pour :

- **Modifier** son contenu réutilisable et ses valeurs par défaut ;
- **Déplacer** le modèle à une autre position dans la liste ;
- **Cacher** le modèle aux personnes qui lancent des votes ; ou
- **Supprimer** un modèle personnalisé qui n’est plus nécessaire.

![La liste des modèles du groupe avec le menu d’actions du modèle de processus de consentement pour un changement de politique ouvert](template_manage.png)

Sélectionnez **Afficher les modèles cachés** pour consulter ou rétablir les modèles cachés. Vous pouvez cacher ou adapter les modèles par défaut pour votre groupe, mais vous ne pouvez pas les supprimer.

Modifier un modèle ne change pas les propositions ou les sondages déjà lancés à partir de celui-ci.

<!-- translation-section: who-can-manage-templates -->

### Qui peut gérer les modèles

Les administrateurs de groupe peuvent créer et gérer tous les modèles de sondage de leur groupe. Ils peuvent activer **Les membres peuvent créer des modèles** dans **Paramètres de groupe** → **Permissions**. Lorsque cette permission est activée, les membres peuvent créer des modèles et gérer ceux dont ils sont les auteurs.
