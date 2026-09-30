---
title: Modèles de sondage
source_revision: 3a315412c646d254c8426be5c436a4e593f6011f
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
  introduction: a44775cbee5af081
  voting-methods-and-templates: 51f239214f34b292
  use-a-template: abb19b99ed8a0351
  who-can-manage-templates: 8b7a94799ce5955d
  create-a-poll-template: 2724f84df46a357c
  template-title-subtitle-and-help: de0d5b8d1d9e9d36
  voting-method: d4035c964dc7d99b
  example-title-details-and-tags: aa28219deb825aea
  response-options: f73b8622cf9c9d3b
  duration-and-settings: 17932de315e03ac8
  save-and-test-the-template: ab4269cb1e361b55
  manage-the-template-list: 884a5ba9e6104d99
title_source: 114cca246e357304
title_generated: cd672e826498e8c7
---

<!-- translation-section: introduction -->

# Modèles de sondage

Les modèles de sondage sont des points de départ réutilisables, proposés lorsque vous sélectionnez **Lancer un vote** ou **Nouveau sondage**. Un modèle associe une méthode de vote à des instructions, des options de réponse et des paramètres prédéfinis.

Cette page explique comment choisir les modèles disponibles pour un groupe ou en créer un pour votre propre processus. Pour choisir un modèle pour un vote précis, consultez [Propositions](../proposals/) ou [Sondages](../proposal_types/). Pour accompagner l’ensemble du processus, consultez [Prendre des décisions](/en/guides/making_decisions/).

<!-- translation-section: voting-methods-and-templates -->

## Méthodes de vote et modèles

La méthode de vote détermine comment les participants répondent et comment Loomio calcule le résultat. Il existe notamment Proposition, Choisir, Score, Allouer, Classer, Sondage horaire de réunion et STV.

Un modèle de sondage utilise l’une de ces méthodes et y ajoute des valeurs par défaut réutilisables. Par exemple, Vérification du ressenti, Avis, Consentement et Consensus sont des modèles différents fondés sur la méthode de vote Proposition. Leurs instructions et leurs options de réponse diffèrent, même si Loomio traite les votes de la même façon.

<!-- translation-section: use-a-template -->

## Utiliser un modèle

Lorsque vous lancez un vote, sélectionnez l’onglet **Proposition** ou **Sondage**, puis choisissez un modèle disponible pour le groupe.

![](proposal_templates_list.png)

Le modèle fournit une introduction, un exemple de contenu, des options et des paramètres. Vérifiez et adaptez ces éléments à la décision avant de lancer le vote. Les modifications apportées au nouveau vote ne changent pas le modèle réutilisable.

<!-- translation-section: who-can-manage-templates -->

## Qui peut gérer les modèles

Les administrateurs d’un groupe peuvent créer et gérer tous ses modèles de sondage. Ils peuvent activer **Les membres peuvent créer des modèles** dans **Paramètres de groupe** → **Permissions**. Les membres peuvent alors créer des modèles et gérer ceux dont ils sont les auteurs.

<!-- translation-section: create-a-poll-template -->

## Créer un modèle de sondage

Ouvrez la liste des modèles et sélectionnez **Nouveau modèle**. Partez d’un exemple ou d’un modèle vierge, puis choisissez le groupe qui l’utilisera.

![](proposal_template_setting.png)

Le formulaire du modèle définit les instructions et les valeurs par défaut proposées aux personnes qui lancent un vote.

![](poll_template_new.png)

<!-- translation-section: template-title-subtitle-and-help -->

### Titre, sous-titre et aide du modèle

- **Titre du modèle** est le nom court affiché dans la liste des modèles.
- **Sous-titre du modèle** explique en une phrase quand l’utiliser.
- **Aide sur les modèles** apparaît dans le panneau d’information lorsque quelqu’un utilise le modèle. Expliquez son objectif, les règles que les participants doivent connaître et, si nécessaire, ajoutez des liens vers les politiques ou guides pertinents.

![](template_WAAP_intro.png)

Choisissez des noms simples et précis pour distinguer ce modèle des autres modèles du groupe.

<!-- translation-section: voting-method -->

### Méthode de vote

Choisissez ce que les participants doivent exprimer et comment le résultat doit être calculé.

![](poll_type_voting_method.png)

- **Proposition** : répondre à une affirmation en choisissant parmi des positions définies ;
- **Choisir** : sélectionner une ou plusieurs options ;
- **Score** : évaluer chaque option sur une échelle ;
- **Allouer** : répartir un nombre limité de points ;
- **Classer** : classer les options par ordre de préférence ;
- **Sondage horaire de réunion** : indiquer ses disponibilités ; et
- **STV** : classer des candidats dans le cadre d’une élection proportionnelle à plusieurs sièges.

Changer de méthode de vote modifie les champs et le calcul du résultat disponibles dans le modèle.

<!-- translation-section: example-title-details-and-tags -->

### Exemple de titre, de détails et d’étiquettes

Fournissez un exemple de contenu pour aider l’auteur à formuler le vote. Ces valeurs sont copiées dans une nouvelle proposition ou un nouveau sondage et peuvent être modifiées avant son lancement.

![](template_WAAP_details.png)

Utilisez des invites plutôt qu’un contenu fixe si chaque utilisation demande un titre ou des détails différents. Ajoutez des étiquettes de catégorie par défaut uniquement si elles s’appliquent à chaque utilisation du modèle.

<!-- translation-section: response-options -->

### Options de réponse

Des méthodes comme Proposition et Choisir permettent de configurer les options de réponse. Sélectionnez l’icône en forme de crayon à côté d’une option pour modifier :

- **Nom de l’option** : le libellé court de la réponse ;
- **Icône** : son repère visuel ;
- **Signification** : ce qu’exprime le choix de cette option ; et
- **Invite de raison** : la question affichée lorsqu’une personne explique sa réponse.

![](poll_type_edit_option.png)

Définissez les options de façon à ce que les participants puissent les distinguer sans avoir à deviner. Leur signification doit correspondre aux règles de décision réellement utilisées par votre groupe.

<!-- translation-section: duration-and-settings -->

### Durée et paramètres

Définissez une durée par défaut adaptée à la plupart des utilisations du modèle. L’auteur peut modifier l’heure de clôture d’un vote particulier.

![](poll_type_duration.png)

D’autres paramètres par défaut peuvent régir la visibilité des résultats, le vote anonyme, le [vote pondéré](../weighted_voting/), l’obligation de justifier son vote, les rappels, le quorum et les fonctions propres à chaque méthode. Consultez [Paramètres des propositions et des sondages](../settings/) pour connaître leurs effets.

<!-- translation-section: save-and-test-the-template -->

### Enregistrer et tester le modèle

Après avoir enregistré le modèle, créez un brouillon de vote à partir de celui-ci. Vérifiez que son introduction, ses invites, ses options et ses paramètres par défaut sont compréhensibles pour une personne qui ne l’a pas créé. Ce brouillon permet aussi de vérifier que la méthode de vote choisie produit le résultat attendu par le groupe.

<!-- translation-section: manage-the-template-list -->

## Gérer la liste des modèles

Utilisez le menu d’actions à côté d’un modèle pour :

- **Modifier** son contenu réutilisable et ses paramètres par défaut ;
- **Déplacer** le modèle à une autre position dans la liste ;
- **Cacher** le modèle aux personnes qui lancent un vote ; ou
- **Supprimer** un modèle personnalisé devenu inutile.

![](template_manage.png)

Sélectionnez **Afficher les modèles cachés** pour examiner ou rétablir les modèles cachés. Les modèles par défaut peuvent être cachés ou adaptés au groupe, mais ils ne peuvent pas être supprimés.

![](template_manage_settings.png)

La modification d’un modèle ne change pas les propositions ou sondages déjà lancés à partir de celui-ci.
