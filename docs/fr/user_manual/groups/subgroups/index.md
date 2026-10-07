---
title: Sous-groupes
source_revision: cd2e1e63e611688362e80009f50b8ed25025ba8b
source_file: docs/en/user_manual/groups/subgroups/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-07'
sections:
  introduction: 63e6e23d24e80919
  add-a-subgroup: 0bc0e5f99eb074c3
  subgroup-settings: 737225cc4bebe7e8
  privacy: 5bdd92ce200f197a
  permissions: ee02991523f1ebe4
  find-subgroups: 5e6fc5a5122c1417
  invite-to-a-subgroup: 0af670e1e9b32a5e
  simultaneously-invite-people-to-subgroups-and-parent-group: 1991604900321cd7
  administer-a-subgroup: 58fa95833f79dd01
  delete-a-subgroup: 2c6e76ec78386443
generated:
  introduction: 5dedb9fedacabb90
  add-a-subgroup: e83e38dd9cd34258
  subgroup-settings: bdd0548ab28d965d
  privacy: 44664bbb51700cfc
  permissions: 5d63fc7094ac3592
  find-subgroups: 8bdb0244966a9a56
  invite-to-a-subgroup: f43723d038795ee2
  simultaneously-invite-people-to-subgroups-and-parent-group: f8892fdd5672d75b
  administer-a-subgroup: 00da0bfa7eaa1f4e
  delete-a-subgroup: 2115bc77d425a1e9
title_source: 9f81e728f70cae3e
title_generated: 93b587493dbb8010
needs_review:
  privacy: check the interface label "**Comment les personnes peuvent-elles rejoindre le groupe ?**" for "**How do people join?**"
---

<!-- translation-section: introduction -->

# Sous-groupes

Les sous-groupes vous aident à organiser vos communications et vos membres pour que les personnes concernées participent au travail commun.

Par exemple, une organisation peut avoir les sous-groupes suivants :
- conseil d’administration
- équipe de travail ou groupe de travail sur un projet
- thème (comme « stratégie » ou « apprentissage »)

Les sous-groupes fonctionnent comme les groupes, mais se trouvent au sein de votre groupe parent. La plupart des fonctionnalités et des paramètres disponibles sont les mêmes que dans le groupe parent. Une personne peut donc être membre de votre sous-groupe, par exemple votre conseil d’administration, sans être membre de votre groupe parent.

<!-- translation-section: add-a-subgroup -->

## Ajouter un sous-groupe

>[!Note]
>La possibilité d’ajouter de nouveaux sous-groupes fait partie des [paramètres d’autorisation](/en/user_manual/groups/settings/permissions) du groupe. Par défaut, seuls les administrateurs peuvent créer de nouveaux sous-groupes.

Pour ajouter un sous-groupe, rendez-vous sur la page de votre groupe principal, puis cliquez sur **Nouveau sous-groupe** dans la barre latérale.  

![Bouton Nouveau sous-groupe dans la barre latérale de la coopérative Oatmilk](subgroups-sidebar.png)

Cliquez sur le bouton **Nouveau sous-groupe**, donnez-lui un nom et choisissez le paramètre de confidentialité, puis cliquez sur **Créer un sous-groupe**.

![Formulaire de création d’un sous-groupe pour le groupe de travail sur les emballages](subgroups_new.png)

Lorsque vous êtes prêt, [invitez des personnes](/en/user_manual/groups/inviting_people/) dans le sous-groupe.

Vous pouvez modifier les [paramètres du groupe](/en/user_manual/groups/settings/) du sous-groupe en cliquant sur l’icône en forme d’engrenage sur sa page.

![Action permettant de modifier les paramètres du groupe de travail sur les emballages](subgroups_edit_group_settings.png)

<!-- translation-section: subgroup-settings -->

## Paramètres du sous-groupe

<!-- translation-section: privacy -->

### Confidentialité

Choisissez qui peut trouver le sous-groupe indépendamment de la manière dont les personnes le rejoignent :

| Confidentialité | Qui peut le trouver | Qui peut lire ses fils |
| --- | --- | --- |
| **Ouvert** | Tout le monde | Tout le monde |
| **Fermé** | Tout le monde | Les membres du sous-groupe et les invités |
| **Visible pour le groupe parent** | Les membres du groupe parent et du sous-groupe | Les membres du sous-groupe et les invités |
| **Secret** | Les membres invités du sous-groupe | Les membres du sous-groupe et les invités |

Pour permettre aux membres du groupe parent de rejoindre le sous-groupe sans approbation, sélectionnez **Visible pour le groupe parent**, puis **Les membres de [groupe parent] peuvent rejoindre le sous-groupe sans approbation** sous **Comment les personnes peuvent-elles rejoindre le groupe ?** lors de la création du sous-groupe, ou dans **Modifier les paramètres du groupe → Confidentialité**. Les personnes extérieures au groupe parent ont besoin d’une invitation. Les membres peuvent quitter le sous-groupe et le rejoindre à nouveau tant qu’ils appartiennent à son groupe parent.

![Paramètres de confidentialité du sous-groupe avec visibilité pour le groupe parent et adhésion sans approbation](subgroups_privacy_settings.png)

En rejoignant le sous-groupe, une personne devient un membre ordinaire. Cela ne lui donne pas le rôle d’administrateur et ne modifie pas la confidentialité des fils existants.

Les sous-groupes publics peuvent également autoriser l’adhésion immédiate ; tout le monde peut les rejoindre lorsque cette option est sélectionnée. Lorsque le groupe parent est privé, les paramètres disponibles pour les sous-groupes sont **Visible pour le groupe parent** et **Secret**.

Un sous-groupe **Visible pour le groupe parent** reste privé lorsque son groupe parent devient public. Rendre un groupe parent privé limite l’accès à ses sous-groupes publics aux membres du groupe parent et rend leurs fils privés, tout en préservant les sous-groupes secrets.

[Consultez les informations sur la confidentialité des groupes](/en/user_manual/groups/settings/privacy).

<!-- translation-section: permissions -->

### Autorisations

Les sous-groupes fonctionnent indépendamment du groupe principal. Par exemple, si le paramètre de confidentialité du sous-groupe est défini sur **Secret**, seuls les membres invités peuvent trouver ce sous-groupe, voir qui en fait partie et consulter ses fils.

Les sous-groupes **Fermés** et les sous-groupes **Visible pour le groupe parent** peuvent permettre aux membres du groupe parent de lire les fils privés avant de les rejoindre. Activez **Les membres de [groupe parent] peuvent voir les fils privés** dans **Permissions**. Ces lecteurs n’obtiennent ni le droit de vote ni le statut de membre du sous-groupe.

![Paramètre permettant aux membres du groupe parent de voir les fils privés du sous-groupe](subgroups_private_threads_settings.png)

<!-- translation-section: find-subgroups -->

## Trouver des sous-groupes

Ouvrez le menu latéral et cliquez sur le nom de votre groupe pour voir ses sous-groupes.

![Sous-groupes de la coopérative Oatmilk affichés dans la barre latérale](subgroups_find_subgroups.png)

<!-- translation-section: invite-to-a-subgroup -->

## Inviter dans un sous-groupe

Invitez des personnes dans un sous-groupe de la même manière que dans un groupe. Si elles appartiennent déjà à un groupe parent ou à un autre sous-groupe de la même organisation dont vous faites également partie, vous pouvez saisir leur nom ou sélectionner ce groupe comme destinataire. Sélectionnez la pastille du groupe destinataire pour afficher chaque personne individuellement, puis retirez les personnes que vous ne souhaitez pas inviter.

<!-- translation-section: simultaneously-invite-people-to-subgroups-and-parent-group -->

### Inviter simultanément des personnes dans des sous-groupes et dans le groupe parent

Si vous utilisez le bouton **Inviter des personnes** depuis l’onglet **Membres** de votre groupe parent, vous pouvez inviter des personnes dans plusieurs sous-groupes à la fois en cochant les cases de ceux que vous souhaitez leur faire rejoindre immédiatement.

![Sélection du groupe parent et du sous-groupe dans le formulaire d’invitation](group_invite_email_subgroups.png)

<!-- translation-section: administer-a-subgroup -->

## Administrer un sous-groupe

Les sous-groupes peuvent avoir leurs propres administrateurs, qui peuvent être différents de ceux du groupe parent.

Toutefois, un administrateur du groupe parent peut se nommer administrateur de n’importe quel sous-groupe. Cela permet aux administrateurs du groupe parent d’administrer les sous-groupes selon les besoins.

Accédez à l’onglet Sous-groupes, trouvez le sous-groupe et cliquez sur **Rejoindre le groupe**.

![Bouton Rejoindre le groupe dans un sous-groupe fermé](member_join_subgroup.png)

Une fois membre du sous-groupe, un administrateur du groupe parent peut se nommer administrateur du sous-groupe.

![Action permettant à un administrateur du groupe parent de se nommer administrateur](member_make_admin.png)

<!-- translation-section: delete-a-subgroup -->

## Supprimer un sous-groupe

Les administrateurs peuvent supprimer un sous-groupe de la même manière qu’un groupe. Lorsque vous supprimez un sous-groupe, veillez à ne pas supprimer le groupe parent.

Découvrez [comment supprimer des groupes](/en/user_manual/groups/deleting_your_group/).
