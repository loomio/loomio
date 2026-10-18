---
title: Modèles de sondage
source_revision: c6076258c3438c0dd6dc8fbf1fc0b0df47c0aeb5
source_file: docs/en/user_manual/polls/poll_templates/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-01'
sections:
  introduction: f11182d62d99dbcc
  voting-methods-and-templates: 24be471686aa2dfd
  use-a-template: 8b19cdf141c41c9b
  who-can-manage-templates: 60218ef791438e19
  create-a-poll-template: c20dd8c57c3deab0
  template-title-subtitle-and-help: 3ad53a8b118aabd3
  voting-method: 761137852812fea8
  example-title-details-and-tags: 9dbbd0510d2d6cc1
  response-options: 727afbf0dcea6069
  duration-and-settings: a364411a3bebb3ae
  save-and-test-the-template: 8c48386c69ea309a
  manage-the-template-list: 0c124d7958c3f80a
generated:
  introduction: 3b5c1e900db47812
  voting-methods-and-templates: 3ae0a1ba990cb7b0
  use-a-template: e6607e25b98dd0f4
  who-can-manage-templates: d1bd889e236e1db2
  create-a-poll-template: b25361f35e9e0e82
  template-title-subtitle-and-help: 270850bbc3fbf63c
  voting-method: 05b2f9a6490adf8a
  example-title-details-and-tags: e5528669c9ec563b
  response-options: 60c3084a72cb9aa0
  duration-and-settings: 7aacad5031a2cb16
  save-and-test-the-template: 94d4c482b1b79ba2
  manage-the-template-list: aa8bbd115e5bb6e5
title_source: 114cca246e357304
title_generated: cd672e826498e8c7
---

<!-- translation-section: introduction -->

# Modèles de sondage

Les modèles de sondage sont des points de départ réutilisables qui s’affichent lorsqu’une personne sélectionne **Lancer un vote** ou **Nouveau sondage**. Un modèle associe une méthode de vote à des consignes, des options de réponse et des paramètres prédéfinis.

Utilisez cette page pour configurer les modèles disponibles dans un groupe ou en créer un pour votre propre processus. Pour choisir un modèle pour un vote particulier, consultez [Propositions](../proposals/) ou [Sondages](../proposal_types/). Pour faciliter un processus de décision complet, consultez [Prendre des décisions](/en/guides/making_decisions/).

<!-- translation-section: voting-methods-and-templates -->

## Méthodes de vote et modèles

Une méthode de vote détermine comment les participants répondent et comment Loomio calcule le résultat. Les méthodes comprennent notamment Proposition, Choisir, Noter, Répartir, Classer, Sondage horaire et STV.

Un modèle de sondage utilise l’une de ces méthodes et y ajoute des valeurs par défaut réutilisables. Par exemple, Prise de température, Avis, Consentement et Consensus sont différents modèles fondés sur la méthode de vote Proposition. Leurs consignes et leurs options de réponse diffèrent, même si Loomio traite leurs bulletins de vote de la même manière.

<!-- translation-section: use-a-template -->

## Utiliser un modèle

Lorsque vous lancez un vote, sélectionnez l’onglet **Proposition** ou **Sondage** et choisissez l’un des modèles disponibles dans le groupe.

![](proposal_templates_list.png)

Le modèle fournit une introduction, un exemple de contenu, des options et des paramètres. Vérifiez et modifiez ces éléments en fonction de la décision à prendre avant de lancer le vote. Modifier le nouveau vote ne change pas le modèle réutilisable.

<!-- translation-section: who-can-manage-templates -->

## Qui peut gérer les modèles

Les administrateurs de groupe peuvent créer et gérer tous les modèles de sondage de leur groupe. Ils peuvent activer **Les membres peuvent créer des modèles** dans **Paramètres de groupe** → **Permissions**. Lorsque cette permission est activée, les membres peuvent créer des modèles et gérer ceux dont ils sont les auteurs.

<!-- translation-section: create-a-poll-template -->

## Créer un modèle de sondage

Ouvrez la liste des modèles et sélectionnez **Nouveau modèle**. Partez d’un exemple ou d’un modèle vierge, puis choisissez le groupe qui l’utilisera.

![](proposal_template_setting.png)

Le formulaire du modèle définit les consignes et les valeurs par défaut fournies aux personnes lorsqu’elles lancent un vote.

![](poll_template_new.png)

<!-- translation-section: template-title-subtitle-and-help -->

### Titre, sous-titre et aide du modèle

- **Titre du modèle** est le nom court affiché dans la liste des modèles.
- **Sous-titre du modèle** explique en une phrase quand l’utiliser.
- **Aide sur les modèles** apparaît dans le panneau d’information lorsqu’une personne utilise le modèle. Expliquez son objectif et les règles que les participants doivent connaître, et ajoutez des liens vers les politiques ou les guides pertinents.

![](template_WAAP_intro.png)

Utilisez des noms simples et précis qui distinguent le modèle des autres modèles du groupe.

<!-- translation-section: voting-method -->

### Méthode de vote

Choisissez ce que les participants doivent exprimer et comment le résultat doit être calculé.

![](poll_type_voting_method.png)

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

Fournissez un exemple de contenu qui aide l’auteur à formuler le vote. Ces valeurs sont copiées dans une nouvelle proposition ou un nouveau sondage et peuvent être modifiées avant son lancement.

![](template_WAAP_details.png)

Utilisez des consignes plutôt qu’un contenu fixe lorsque chaque utilisation nécessite un titre ou des détails différents. Ajoutez des tags de catégorie par défaut uniquement s’ils s’appliquent à chaque utilisation du modèle.

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

![](poll_type_duration.png)

D’autres paramètres par défaut peuvent déterminer la visibilité des résultats, le vote anonyme, le [vote pondéré](../weighted_voting/), l’obligation de fournir une raison du vote, les rappels, le quorum et le fonctionnement propre à chaque méthode. Consultez [Paramètres des propositions et des sondages](../settings/) pour connaître leurs effets.

<!-- translation-section: save-and-test-the-template -->

### Enregistrer et tester le modèle

Après l’enregistrement, créez un brouillon de vote à partir du modèle. Vérifiez que son introduction, ses consignes, ses options et ses valeurs par défaut sont compréhensibles pour une personne qui ne l’a pas créé. Créer un brouillon permet aussi de confirmer que la méthode de vote choisie produit le résultat attendu par le groupe.

<!-- translation-section: manage-the-template-list -->

## Gérer la liste des modèles

Utilisez le menu d’actions à côté d’un modèle pour :

- **Modifier** son contenu réutilisable et ses valeurs par défaut ;
- **Déplacer** le modèle à une autre position dans la liste ;
- **Cacher** le modèle aux personnes qui lancent des votes ; ou
- **Supprimer** un modèle personnalisé qui n’est plus nécessaire.

![](template_manage.png)

Sélectionnez **Afficher les modèles cachés** pour consulter ou rétablir les modèles cachés. Les modèles par défaut peuvent être cachés ou adaptés au groupe, mais ne peuvent pas être supprimés.

![](template_manage_settings.png)

Modifier un modèle ne change pas les propositions ou les sondages déjà lancés à partir de celui-ci.
