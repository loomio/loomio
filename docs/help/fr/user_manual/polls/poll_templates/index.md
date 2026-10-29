---
title: Modèles de sondage
source_revision: 00d781409c832b216c95759c1369678ad240e246
source_file: docs/help/en/user_manual/polls/poll_templates/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-29'
sections:
  introduction: a535465485cdbc13
  who-can-manage-templates: 6c3d5e693cd1dfdc
  create-a-poll-template: 0fafc6275b6c9153
  template-title-subtitle-and-help: 5a3f6c78e32fb066
  voting-method: c645269a1a17d1c8
  example-title-details-and-tags: 0f0d84a8b9b6ecb2
  response-options: 727afbf0dcea6069
  duration-and-settings: f1f3643e94524af9
  manage-the-template-list: 76e78b8a60f1d08c
  save-a-poll-as-a-template: 36dc7b5d410d0eea
  start-a-new-template: 4f14910d88b22de8
  configure-the-template: bec89f7804dd12f8
  edit-a-default-template: 6f1e7050d20ed373
generated:
  introduction: f618ac9c58fb2d1b
  who-can-manage-templates: 8415575d22a226aa
  create-a-poll-template: 1334d2e3d3d73853
  template-title-subtitle-and-help: 344248e8b3992859
  voting-method: dadde6a8c85262e6
  example-title-details-and-tags: acd0018624924a32
  response-options: 60c3084a72cb9aa0
  duration-and-settings: fd3770d58d5efd92
  manage-the-template-list: d5fb47d49b03482d
  save-a-poll-as-a-template: 382da00f01cd87df
  start-a-new-template: 12253dceea1c3b74
  configure-the-template: 212b0fbb68e5604c
  edit-a-default-template: 8e612d7b6c8ef601
title_source: 114cca246e357304
title_generated: cd672e826498e8c7
---

<!-- translation-section: introduction -->

# Modèles de sondage

Les modèles de sondage sont des points de départ réutilisables qui s’affichent lorsqu’une personne sélectionne **Lancer un vote** ou **Nouveau sondage**. Un modèle associe une méthode de vote à des consignes, des options de réponse et des paramètres prédéfinis.

Utilisez cette page pour configurer les modèles disponibles dans un groupe ou en créer un pour votre propre processus. Pour choisir un modèle pour un vote particulier, consultez [Propositions](../proposals/) ou [Sondages](../proposal_types/). Pour faciliter un processus de décision complet, consultez [Prendre des décisions](/en/guides/making_decisions/).

Lorsque vous lancez un vote, sélectionnez l’onglet **Proposition** ou **Sondage** et choisissez l’un des modèles disponibles dans le groupe.

Le modèle fournit une introduction, un exemple de contenu, des options et des paramètres. Vérifiez et adaptez ces éléments à la décision concernée avant de lancer le vote. Modifier le nouveau vote ne change pas le modèle réutilisable.

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

Donnez au modèle un nom et un sous-titre qui indiquent quand l’utiliser. Vous pouvez modifier tous les autres champs pour les rendre plus adaptés à la réutilisation. Après avoir sélectionné **Enregistrer le modèle**, le modèle apparaîtra dans la liste lorsqu’une personne lancera une nouvelle proposition ou un nouveau sondage.

[![Le formulaire complet du modèle de processus de consentement pour un changement de politique](poll_template_new.png)](poll_template_new.png)

<!-- translation-section: template-title-subtitle-and-help -->

### Titre, sous-titre et aide du modèle

Utilisez le titre et le sous-titre pour expliquer quand choisir le modèle. Ajoutez les consignes sur le processus, les règles de décision et les liens vers des ressources dans **Aide sur les modèles**.

<!-- translation-section: voting-method -->

### Méthode de vote

Choisissez ce que les participants doivent exprimer et comment le résultat doit être calculé.

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
- **Invite de raison** : la question affichée lorsqu’une personne explique sa réponse.

![](poll_type_edit_option.png)

Définissez les options pour que les participants puissent les distinguer sans avoir à deviner leur sens. Les significations doivent correspondre aux règles de décision que votre groupe utilise réellement.

<!-- translation-section: duration-and-settings -->

### Durée et paramètres

Définissez une durée par défaut adaptée à la plupart des utilisations du modèle. L’auteur peut modifier l’heure de clôture d’un vote particulier.

D’autres paramètres par défaut peuvent déterminer la visibilité des résultats, le vote anonyme, le [vote pondéré](../weighted_voting/), l’obligation de fournir une raison du vote, les rappels, le quorum et le fonctionnement propre à chaque méthode. Consultez [Paramètres des propositions et des sondages](../settings/) pour connaître leurs effets.

<!-- translation-section: manage-the-template-list -->

## Gérer les modèles

Utilisez le menu d’actions à côté d’un modèle pour :

- **Modifier** son contenu réutilisable et ses valeurs par défaut ;
- **Déplacer** le modèle à une autre position dans la liste ;
- **Cacher** le modèle aux personnes qui lancent des votes ; ou
- **Supprimer** un modèle personnalisé qui n’est plus nécessaire.

![La liste des modèles du groupe avec le menu d’actions du modèle de processus de consentement pour un changement de politique ouvert](template_manage.png)

Sélectionnez **Afficher les modèles cachés** pour consulter ou rétablir les modèles cachés. Les modèles par défaut peuvent être cachés ou adaptés au groupe, mais ne peuvent pas être supprimés.

Modifier un modèle ne change pas les propositions ou les sondages déjà lancés à partir de celui-ci.

<!-- translation-section: who-can-manage-templates -->

### Qui peut gérer les modèles

Les administrateurs de groupe peuvent créer et gérer tous les modèles de sondage de leur groupe. Ils peuvent activer **Les membres peuvent créer des modèles** dans **Paramètres de groupe** → **Permissions**. Lorsque cette permission est activée, les membres peuvent créer des modèles et gérer ceux dont ils sont les auteurs.
