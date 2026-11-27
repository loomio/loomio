---
title: Mots-clés de catégorie
source_revision: 95ce9afd64c99656f67e05a09fa9fc8a77af51d7
source_file: docs/help/en/user_manual/discussions/tags/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-11-26'
sections:
  introduction: 6cccb1690d444dd2
  apply-tags: dfa06440d6c97396
  create-tags: 97aa7a1a0f420951
  edit-tags: bb9dfb8a5abe7a27
  edit-tag-in-thread-or-poll: b71467aa1248d110
  template-tags: 3ddcc6c204aa843f
  tag-contributions: b42bdd723f9d5ddc
  find-tagged-contributions: 98ec0cbfdec75f7f
  global-search: 5a7777699988e006
generated:
  introduction: a83b00ac01956690
  apply-tags: 2eccd45b026f9f16
  create-tags: 56406dc5b6815707
  edit-tags: 6937f09b966f7f34
  edit-tag-in-thread-or-poll: 6df195c747275c2b
  template-tags: 0b29a008a67c8285
  tag-contributions: 42d4126042de8392
  find-tagged-contributions: 2de84ba44859e728
  global-search: b86c1fe1437a5826
title_source: c86f6830bf302394
title_generated: 1c61afd81272cea4
---

<!-- translation-section: introduction -->

# Tags de catégorie

Les tags de catégorie vous aident à retrouver les discussions, les sondages, les conclusions et les commentaires portant sur un sujet ou un domaine de travail.

Les tags appartiennent à l’ensemble de l’organisation. Un tag créé dans un groupe parent est partagé avec ses sous-groupes, ce qui vous permet de suivre les travaux liés entre eux dans plusieurs groupes. Loomio affiche les tags par ordre alphabétique avec un point de couleur à côté de chaque nom.

Sur **Tous les groupes** ou sur la page d’un groupe, sélectionnez **Mots-clés** au-dessus de la liste des fils, des sondages ou des tâches et choisissez un tag pour afficher les éléments portant ce tag. Saisissez du texte dans le champ de filtrage pour rechercher dans une longue liste.

![](tags_view.png)

<!-- translation-section: apply-tags -->

## Appliquer des tags

Vous pouvez appliquer des tags à vos propres discussions, sondages, conclusions et commentaires. Les administrateurs de groupe, les administrateurs de fil et les personnes autorisées à modifier le contexte de la discussion peuvent appliquer des tags à tout élément dans un fil non verrouillé. Dans les fils directs, tous les participants peuvent appliquer des tags à tout élément.

Lorsque vous créez un fil ou un sondage, sélectionnez le champ **Mots-clés** et choisissez un ou plusieurs tags.

![](tags_add_new.png)

Commencez à saisir du texte pour filtrer la liste. Pour retirer un tag, sélectionnez-le à nouveau ou sélectionnez **×** sur le tag.

<!-- translation-section: create-tags -->

## Créer des tags

La création de tags dépend des rôles et des autorisations dans le groupe :

- Les **administrateurs du groupe parent** peuvent toujours créer des tags pour le groupe parent et ses sous-groupes.
- Les **administrateurs des sous-groupes** peuvent créer des tags lorsqu’ils en appliquent au contenu de leur sous-groupe.
- Les **Membres du groupe** qui peuvent appliquer des tags au contenu peuvent aussi en créer lorsque l’autorisation **Les membres peuvent créer des tags** est activée (elle l’est par défaut). Si un administrateur du groupe la désactive, les membres peuvent uniquement utiliser les tags existants de l’organisation et les tags par défaut des modèles de ce groupe.

Pour créer un tag lors de la création d’un fil ou d’un sondage, saisissez son nom dans le champ **Mots-clés** et appuyez sur Entrée.

![Créer un nouveau tag](tags_create_new.png)

![Nouveau tag créé](tags_created_new.png)

Utilisez des noms courts et reconnaissables, comme Finances, Gouvernance, Emballage ou Partenariats avec des cafés.

<!-- translation-section: template-tags -->

## Tags dans les modèles

Les modèles de discussion et de sondage enregistrent des noms de tags par défaut. Toute personne pouvant créer ou modifier un modèle peut changer ses tags par défaut. L’enregistrement d’un modèle n’ajoute pas ces noms à la liste des tags de l’organisation, et renommer ou supprimer un tag de l’organisation ne modifie pas les valeurs par défaut des modèles.

Lorsqu’une personne crée une discussion ou un sondage à partir d’un modèle, Loomio applique les tags correspondants de l’organisation ou en crée de nouveaux si l’auteur en a l’autorisation :

- Les **membres qui peuvent créer des tags** conservent tous les tags par défaut du modèle.
- Les **membres sans autorisation de créer des tags** conservent les tags existants de l’organisation et tous les tags par défaut définis par les modèles du groupe de destination. Les noms de tags provenant du modèle d’un autre groupe qui ne correspondent à aucun de ces tags sont ignorés.

<!-- translation-section: edit-tags -->

## Modifier les tags

Seuls les administrateurs du groupe parent peuvent renommer les tags, changer leur couleur, les fusionner ou les supprimer. Les modifications s’appliquent à l’ensemble de l’organisation, y compris à tous les sous-groupes.

Sur la page du groupe, ouvrez **Mots-clés** et sélectionnez **Modifier les mots-clés**, ou ouvrez **Paramètres** et sélectionnez **Classement par tags**.

![Modifier les tags de catégorie](tags_edit_new.png)

Sélectionnez l’icône de crayon à côté d’un tag pour le modifier.

![Modifier les tags de catégorie](tags_edit_new_pencil.png)

Modifiez le nom du tag ou choisissez une couleur, puis sélectionnez **Enregistrer**.

![Modifier la couleur du tag](tags_edit_name.png)

Pour fusionner un tag avec un autre, sélectionnez l’icône de fusion à côté de ce tag et choisissez le tag à conserver. Tous les éléments portant l’ancien tag reçoivent le tag choisi à la place.

Pour supprimer un tag, sélectionnez **Supprimer** (ou l’icône de corbeille). Le tag est alors retiré de toutes les discussions, de tous les sondages, de toutes les conclusions et de tous les commentaires de l’organisation.

![Supprimer un tag](tags_delete.png)

<!-- translation-section: edit-tag-in-thread-or-poll -->

### Modifier les tags d’un fil ou d’un sondage

Pour modifier les tags d’un fil ou d’un sondage existant, ouvrez-le et sélectionnez le bouton des tags à côté de ses tags actuels, près du titre.

Sélectionnez des tags pour les ajouter ou les retirer. Les modifications sont enregistrées immédiatement.

Le sélecteur affiche les tags utilisés dans le groupe actuel, les tags inutilisés de l’organisation et les tags sélectionnés pour l’élément. Dans une organisation comportant plusieurs groupes, sélectionnez **Afficher les tags des autres groupes** pour inclure les tags utilisés uniquement dans d’autres groupes, ou **Afficher les étiquettes utilisées dans ce groupe** pour réduire à nouveau la liste.

![Modifier les tags d’un fil](tags_thread_edit.png)

<!-- translation-section: tag-contributions -->

## Appliquer des tags aux contributions

Ouvrez le menu à trois points (**⋯**) d’un sondage, d’une conclusion ou d’un commentaire et sélectionnez **Appliquer les mots-clés**. Ajoutez ou retirez des tags dans le sélecteur ; les modifications sont enregistrées immédiatement. Lorsqu’une contribution porte des tags, ses tags et le bouton des tags apparaissent à droite de la ligne indiquant son auteur.

Les tags s’appliquent à l’élément que vous sélectionnez. Il n’est pas possible d’appliquer des tags aux votes ni aux bulletins de vote.

<!-- translation-section: find-tagged-contributions -->

## Retrouver les contributions portant des tags

Lorsqu’un commentaire, un sondage ou une conclusion dans un fil porte un tag, une section **Mots-clés** apparaît dans la barre latérale du fil (ou dans le volet de navigation sur mobile).

Sélectionnez un tag pour filtrer le fil et afficher les éléments correspondants ainsi que les éléments auxquels ils répondent. Pour revenir au fil complet, sélectionnez **×** dans la barre de filtrage, sélectionnez à nouveau le tag ou sélectionnez **Vider** dans la barre latérale.

![Tags dans la barre latérale du fil](tags_thread_sidebar.png)

<!-- translation-section: global-search -->

## Rechercher par tag

Ouvrez **Rechercher** dans la navigation supérieure et sélectionnez votre groupe parent pour afficher le menu des tags. Choisissez un tag pour trouver les discussions, les sondages, les conclusions et les commentaires portant ce tag.

Laissez le champ de recherche vide pour parcourir les éléments par tag, ou saisissez des mots-clés pour rechercher parmi les éléments portant ce tag. Sélectionnez **N'importe quel tag** pour effacer le filtre.

![Sélection d’un tag dans la recherche globale après avoir choisi le groupe parent](tags_global_search.png)
