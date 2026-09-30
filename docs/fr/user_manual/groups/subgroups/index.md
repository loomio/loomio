---
title: Sous-groupes
source_revision: 7a01b0fd7d7df0c4bca327a916b01b12e62b967f
source_file: docs/user_manual/groups/subgroups/index.md
translated:
  provider: codex/gpt-6-sol
  'on': '2026-09-29'
sections:
  introduction: 63e6e23d24e80919
  add-a-subgroup: 0bc0e5f99eb074c3
  subgroup-settings: 737225cc4bebe7e8
  privacy: f5d6a140045a00af
  permissions: 948f8a0f3209953c
  find-subgroups: 5e6fc5a5122c1417
  invite-to-a-subgroup: 0af670e1e9b32a5e
  simultaneously-invite-people-to-subgroups-and-parent-group: 1991604900321cd7
  administer-a-subgroup: 58fa95833f79dd01
  delete-a-subgroup: 2c6e76ec78386443
generated:
  introduction: '08f30057c474f968'
  add-a-subgroup: b79708ed463c366d
  subgroup-settings: 6e6985c14122d02d
  privacy: 4154c02322d1ec37
  permissions: 5a9f0541c6ee2e75
  find-subgroups: 117668401171b2cd
  invite-to-a-subgroup: fbc859e694c6b752
  simultaneously-invite-people-to-subgroups-and-parent-group: 9ce2c835d17889e9
  administer-a-subgroup: 823d3ec4420bff1f
  delete-a-subgroup: 2ce6c25adf89aec3
title_source: 9f81e728f70cae3e
title_generated: 93b587493dbb8010
---

<!-- translation-section: introduction -->

# Sous-groupes

Les sous-groupes vous aident à organiser vos échanges et vos membres pour que les bonnes personnes travaillent ensemble.

Par exemple, une organisation peut avoir les sous-groupes suivants :
- un conseil de gouvernance
- une équipe ou un groupe de travail sur un projet
- un groupe consacré à un sujet, comme la stratégie ou l’apprentissage

Les sous-groupes fonctionnent comme les groupes, mais se trouvent au sein de votre groupe « parent ». Ils disposent de la plupart des mêmes fonctionnalités et paramètres. Une personne peut donc être membre d’un sous-groupe, comme votre conseil, sans être membre du groupe parent.

<!-- translation-section: add-a-subgroup -->

## Ajouter un sous-groupe

>[!Note]
>La possibilité d’ajouter des sous-groupes dépend des [paramètres d’autorisation](/en/user_manual/groups/settings/permissions) du groupe. Par défaut, seuls les administrateurs peuvent créer des sous-groupes.

Pour ajouter un sous-groupe, ouvrez la page de votre groupe principal, puis cliquez sur **Nouveau sous-groupe** dans la barre latérale.

![Bouton Nouveau sous-groupe dans la barre latérale d’Oatmilk Cooperative](subgroups-sidebar.png)

Cliquez sur **Nouveau sous-groupe**, donnez-lui un nom et choisissez un paramètre de confidentialité, puis cliquez sur **Créer un sous-groupe**.

![Formulaire de création d’un sous-groupe pour le groupe de travail sur l’emballage](subgroups_new.png)

Lorsque vous êtes prêt, [invitez des personnes](/en/user_manual/groups/inviting_people/) dans le sous-groupe.

Pour modifier les [paramètres du groupe](/en/user_manual/groups/settings/) du sous-groupe, cliquez sur l’icône en forme d’engrenage sur sa page.

![Action de modification des paramètres du groupe de travail sur l’emballage](subgroups_edit_group_settings.png)

<!-- translation-section: subgroup-settings -->

## Paramètres des sous-groupes

<!-- translation-section: privacy -->

### Confidentialité

Les paramètres de confidentialité des sous-groupes sont semblables à ceux du groupe parent.

Les sous-groupes **Secret** ne sont pas visibles par les personnes qui n’y ont pas été invitées.

Les sous-groupes **Fermé** figurent dans l’onglet Sous-groupes du groupe parent et dans le menu latéral des utilisateurs. Les membres du groupe parent peuvent demander à rejoindre le sous-groupe. Un administrateur du sous-groupe approuve leur adhésion.

Les sous-groupes fermés disposent d’un paramètre supplémentaire qui permet aux membres du groupe parent de voir les fils de discussion privés.

[En savoir plus sur la confidentialité des groupes](/en/user_manual/groups/settings/privacy).

<!-- translation-section: permissions -->

### Autorisations

Les sous-groupes fonctionnent indépendamment du groupe principal. Par exemple, si la confidentialité d’un sous-groupe est réglée sur **Secret**, seuls les membres invités peuvent le trouver, voir qui en fait partie et consulter ses fils de discussion.

Les sous-groupes **Fermé** disposent d’un paramètre supplémentaire qui permet aux membres du groupe parent de voir les fils de discussion privés du sous-groupe.

![Paramètre permettant aux membres du groupe parent de voir les fils de discussion privés du sous-groupe](subgroups_private_threads_settings.png)

<!-- translation-section: find-subgroups -->

## Trouver des sous-groupes

Ouvrez le menu latéral et cliquez sur le nom de votre groupe pour voir ses sous-groupes.

![Sous-groupes d’Oatmilk Cooperative dans la barre latérale](subgroups_find_subgroups.png)

<!-- translation-section: invite-to-a-subgroup -->

## Inviter des personnes dans un sous-groupe

Invitez des personnes dans un sous-groupe comme vous le feriez pour un groupe. Si elles appartiennent déjà à un groupe parent ou à un autre sous-groupe de la même organisation dont vous êtes également membre, vous pouvez saisir leur nom ou sélectionner ce groupe comme destinataire de l’invitation. Cliquez sur la pastille des destinataires pour afficher chaque personne, puis retirez celles que vous ne souhaitez pas inviter.

<!-- translation-section: simultaneously-invite-people-to-subgroups-and-parent-group -->

### Inviter des personnes dans plusieurs sous-groupes et dans le groupe parent

Si vous utilisez le bouton **Inviter des personnes** dans l’onglet **Membres** de votre groupe parent, vous pouvez inviter des personnes dans plusieurs sous-groupes à la fois. Cochez les cases des sous-groupes qu’elles doivent rejoindre immédiatement.

![Sélection du groupe parent et d’un sous-groupe dans le formulaire d’invitation](group_invite_email_subgroups.png)

<!-- translation-section: administer-a-subgroup -->

## Administrer un sous-groupe

Un sous-groupe peut avoir ses propres administrateurs, qui peuvent être différents de ceux du groupe parent.

Un administrateur du groupe parent peut toutefois devenir administrateur de n’importe lequel de ses sous-groupes. Cela lui permet de les administrer au besoin.

Ouvrez l’onglet Sous-groupes, trouvez le sous-groupe et cliquez sur **Rejoindre le groupe**.

![Bouton Rejoindre le groupe sur un sous-groupe fermé](member_join_subgroup.png)

Une fois membre du sous-groupe, l’administrateur du groupe parent peut se donner le rôle d’administrateur du sous-groupe.

![Action permettant à un administrateur du groupe parent de devenir administrateur du sous-groupe](member_make_admin.png)

<!-- translation-section: delete-a-subgroup -->

## Supprimer un sous-groupe

Les administrateurs peuvent supprimer un sous-groupe de la même manière qu’un groupe. Veillez à ne pas supprimer le groupe parent.

Découvrez [comment supprimer un groupe](/en/user_manual/groups/deleting_your_group/).
