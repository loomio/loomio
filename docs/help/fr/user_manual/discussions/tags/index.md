---
title: Mots-clés de catégorie
source_revision: 316c5c5d81b1ba8cd814d678f48deae613a09ff2
source_file: docs/help/en/user_manual/discussions/tags/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-27'
sections:
  introduction: a898970462d0556f
  apply-tags: 86f59d27fd31c89f
  create-tags: a73c85e12ffa1e16
  edit-tags: f2ad1debf84eb70f
  edit-tag-in-thread-or-poll: a1c9e538d0d30424
  template-tags: a7cd2b824613855c
  tag-contributions: 133105ee90747934
  find-tagged-contributions: 88ea04f0fde7cb1a
  global-search: 597afa36d4894500
generated:
  introduction: 51be55fc0209c435
  apply-tags: d0c4c82f12cb78e8
  create-tags: '080c17c23940f547'
  edit-tags: 8b7306cbb1c85b6a
  edit-tag-in-thread-or-poll: 17ed72f6d190cef1
  template-tags: cfbff2f2978ac3d9
  tag-contributions: bdc0942345dd720d
  find-tagged-contributions: d866365b0ffdcc04
  global-search: 5866910c4ba73aef
title_source: c86f6830bf302394
title_generated: 1c61afd81272cea4
---

<!-- translation-section: introduction -->

# Tags de catégorie

Les tags de catégorie permettent de retrouver les discussions, les sondages, les conclusions et les commentaires portant sur un type de travail ou un sujet particulier.

Les tags appartiennent à l’ensemble de l’organisation. Un tag utilisé dans un groupe parent est le même dans ses sous-groupes, ce qui permet d’organiser les travaux liés entre eux dans toute l’organisation. Loomio affiche les noms des tags par ordre alphabétique et représente leurs couleurs par des points à côté des noms.

Sur la page de votre groupe, cliquez sur **Mots-clés** au-dessus de la liste des fils. Sélectionnez un tag pour afficher les fils contenant au moins une contribution portant ce tag. Utilisez le champ de filtrage pour rechercher dans une longue liste.

![](tags_view.png)

<!-- translation-section: apply-tags -->

## Appliquer des tags

Vous pouvez appliquer des tags à vos propres discussions, sondages, conclusions et commentaires. Les administrateurs de groupe, les administrateurs de fil et les personnes autorisées à modifier le contexte de la discussion peuvent appliquer des tags à toute contribution dans un fil non verrouillé. Dans les fils directs, tous les participants peuvent appliquer des tags à toute contribution.

Lorsque vous créez un fil ou un sondage, cliquez sur le champ **Mots-clés** et sélectionnez un ou plusieurs tags.

![](tags_add_new.png)

Commencez à saisir du texte pour filtrer la liste. Pour retirer un tag, sélectionnez-le à nouveau ou cliquez sur le × de sa pastille.

<!-- translation-section: create-tags -->

## Créer des tags

Les administrateurs du groupe parent peuvent toujours créer des tags pour le groupe parent et ses sous-groupes. Les administrateurs des sous-groupes peuvent créer des tags lorsqu’ils en appliquent au contenu de leur sous-groupe. L’autorisation du groupe **Les membres peuvent créer des tags**, activée par défaut, permet aux autres membres qui peuvent appliquer des tags au contenu de créer de nouveaux noms de tags. Si cette autorisation est désactivée, les membres peuvent utiliser les tags existants de l’organisation et les noms de tags prévus par les modèles du groupe de destination.

Pour créer un tag lors de la création d’un fil ou d’un sondage, saisissez son nom dans le champ **Mots-clés** et appuyez sur Entrée.

![Créer un nouveau tag](tags_create_new.png)

![Nouveau tag créé](tags_created_new.png)

Utilisez des noms courts et familiers que les membres du groupe reconnaîtront, comme Finances, Gouvernance, Emballage ou Partenariats avec des cafés.

<!-- translation-section: template-tags -->

## Tags dans les modèles

Les modèles de discussion et de sondage enregistrent des noms de tags par défaut. Toute personne pouvant créer ou modifier un modèle peut librement changer ses noms de tags. L’enregistrement ou la consultation d’un modèle n’ajoute pas ces noms à la liste des tags de l’organisation. Renommer ou supprimer un tag de l’organisation ne modifie pas les valeurs par défaut des modèles.

Lorsqu’une discussion ou un sondage utilise ces valeurs par défaut, Loomio applique un tag existant de l’organisation ou le crée si cela est autorisé. Un membre qui n’a pas l’autorisation de créer des tags peut tout de même utiliser les noms prévus par les modèles disponibles dans le groupe de destination. Un modèle provenant d’un autre groupe n’accorde aucune autorisation supplémentaire de création de tags : ses valeurs par défaut sont conservées uniquement si l’organisation de destination possède déjà ces tags ou si un modèle du groupe de destination prévoit ces noms. Les autres noms sont ignorés. Les membres qui peuvent créer des tags peuvent conserver toutes les valeurs par défaut du modèle.

<!-- translation-section: edit-tags -->

## Modifier les tags

Seuls les administrateurs du groupe parent peuvent renommer les tags, changer leur couleur, les fusionner ou les supprimer. Ces modifications s’appliquent partout où ces tags sont utilisés dans l’organisation, y compris dans ses sous-groupes.

Sur la page du groupe, ouvrez **Mots-clés** et sélectionnez **Modifier les mots-clés**.

![Modifier les tags de catégorie](tags_edit_new.png)

Sélectionnez l’icône de crayon à côté d’un tag.

![Modifier les tags de catégorie](tags_edit_new_pencil.png)

Modifiez le nom du tag ou choisissez une couleur, puis cliquez sur **Enregistrer**.

![Modifier la couleur du tag](tags_edit_name.png)

Cliquez sur **Supprimer** pour retirer le tag des discussions, des sondages, des conclusions et des commentaires dans toute l’organisation.

![Supprimer un tag](tags_delete.png)

<!-- translation-section: edit-tag-in-thread-or-poll -->

### Modifier les tags d’un fil ou d’un sondage

Pour modifier les tags d’un fil ou d’un sondage existant, ouvrez-le et cliquez sur le bouton des tags à côté de ses tags actuels, près du titre.

Sélectionnez des tags pour les ajouter ou les retirer. Les modifications sont enregistrées immédiatement.

Le sélecteur affiche les tags utilisés dans le groupe actuel, les tags inutilisés de l’organisation et les tags sélectionnés pour la contribution. Lorsque d’autres tags sont utilisés uniquement dans d’autres groupes, choisissez **Afficher les tags des autres groupes** pour inclure les tags du groupe parent et de ses sous-groupes au sein de la même organisation. Choisissez **Afficher les étiquettes utilisées dans ce groupe** pour revenir à la liste plus courte. Une organisation ne comportant qu’un seul groupe ne dispose pas d’option permettant d’élargir la liste.

![Modifier les tags d’un fil](tags_thread_edit.png)

<!-- translation-section: tag-contributions -->

## Appliquer des tags aux contributions

Ouvrez le menu d’actions d’un sondage, d’une conclusion ou d’un commentaire et sélectionnez **Appliquer les mots-clés**. Le même sélecteur que celui utilisé à côté du titre de la discussion vous permet d’ajouter ou de retirer des tags. Les modifications sont enregistrées immédiatement. Lorsqu’une contribution porte des tags, leurs pastilles et le bouton des tags apparaissent à droite de la ligne indiquant son auteur et son horodatage.

Les tags s’appliquent à la contribution que vous sélectionnez. Il n’est pas possible d’appliquer des tags aux votes ni aux bulletins de vote.

<!-- translation-section: find-tagged-contributions -->

## Retrouver les contributions portant des tags

La section **Mots-clés** apparaît dans la barre latérale du fil dès qu’une contribution autre que la discussion ou le sondage initial porte des tags. Elle rassemble les tags de l’élément initial et de toutes les autres contributions portant des tags. Sélectionnez un tag pour afficher les contributions correspondantes avec le contexte de leur élément parent. Une barre d’outils reste visible au-dessus du fil tant que le filtre est actif. Fermez-la avec le bouton × à droite, sélectionnez à nouveau le tag ou choisissez **Vider** dans la barre latérale pour revenir à l’affichage habituel du fil. Sur mobile, ouvrez le volet de navigation du fil pour utiliser le même filtre.

![Tags dans la barre latérale du fil](tags_thread_sidebar.png)

<!-- translation-section: global-search -->

## Rechercher par tag

Ouvrez **Rechercher** dans la navigation supérieure et sélectionnez votre groupe parent pour afficher le menu des tags. Choisissez un tag pour trouver les discussions, sondages, conclusions et commentaires portant ce tag.

Laissez le champ de recherche vide pour parcourir les contributions par tag, ou saisissez un mot ou une expression pour rechercher parmi les contributions portant ce tag. Sélectionnez **N'importe quel tag** pour effacer le filtre par tag.

![Sélection d’un tag dans la recherche globale après avoir choisi le groupe parent](tags_global_search.png)
