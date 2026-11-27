---
title: Gestion des membres
source_revision: 95ce9afd64c99656f67e05a09fa9fc8a77af51d7
source_file: docs/help/en/user_manual/groups/member_management/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-11-26'
sections:
  introduction: bc7d2de9abc2ea86
  administering-your-group: 7ae1b105c20977fc
  managing-subgroups: 2e4bdee3283e8ef8
  removing-members: d70807bdd968d594
  leaving-group: 69332aeda981c679
  set-title: eb9a52e3d6c21d43
  member-email-addresses: 0e800419a7bdacc6
generated:
  introduction: 05cb67a281f7dd87
  administering-your-group: c46f5e0dc6e4e458
  managing-subgroups: 8ada1df8255a58a0
  removing-members: 655df70dc2e10436
  leaving-group: 6952c4b9cf52388f
  set-title: 040a7509d74c0576
  member-email-addresses: 40f5508af2f6d264
title_source: 23ac3a7fe9ee72a2
title_generated: b31caad0ffc3a452
---

<!-- translation-section: introduction -->

# Gestion des membres

Les administrateurs du groupe gèrent les membres depuis l’onglet **Membres** sur la page du groupe. Ouvrez le menu des actions à côté d’un membre pour définir son rôle, le nommer administrateur du groupe, le nommer délégué ou le retirer du groupe.

![Menu des actions sur un membre sur la page des membres de la coopérative Oatmilk](member_management.png)

<!-- translation-section: administering-your-group -->

## Administrer votre groupe

Un groupe Loomio comporte deux rôles : **membre** et **administrateur du groupe**.

Les administrateurs du groupe peuvent ajouter et retirer des membres, gérer les permissions des membres, modifier les paramètres de confidentialité du groupe, gérer les abonnements, consulter les adresses e-mail des membres et exporter les données du groupe.

La personne qui crée un groupe est administrateur du groupe par défaut. Nous vous recommandons d’avoir au moins deux administrateurs du groupe afin que quelqu’un puisse toujours gérer le groupe. Un groupe peut avoir autant d’administrateurs que nécessaire.

Pour nommer un membre administrateur du groupe, ouvrez le menu des actions à côté de son nom dans l’onglet **Membres** et sélectionnez **Nommer admin**.

![Action Nommer admin dans le menu d’un membre](member_make_admin.png)

<!-- translation-section: managing-subgroups -->

## Gérer les sous-groupes

Les administrateurs d’un groupe parent peuvent rejoindre tout sous-groupe non secret, puis se nommer administrateurs de ce sous-groupe.

Sélectionnez **Rejoindre le groupe** sur la page du sous-groupe.

![Bouton Rejoindre le groupe dans un sous-groupe fermé de la coopérative Oatmilk](member_join_subgroup.png)

Une fois membre du sous-groupe, ouvrez le menu des actions à côté de votre nom dans son onglet **Membres** et sélectionnez **Nommer admin**.

>[!Note]
>Cela ne s’applique pas aux [sous-groupes **Secret**](/en/user_manual/groups/subgroups#permissions).

<!-- translation-section: removing-members -->

## Retirer des membres

Pour retirer une personne, ouvrez le menu des actions à côté de son nom et sélectionnez **Retirer du groupe**.

![Action Retirer du groupe dans le menu d’un membre](member_remove.png)

Lorsqu’une personne est retirée d’un groupe :

- Elle perd l’accès au groupe et à ses sous-groupes et ne reçoit plus de notifications du groupe.
- Ses commentaires et ses votes existants restent inchangés.
- Les sondages privés disparaissent de son tableau de bord et de sa liste des votes. Les sondages publics restent consultables, mais elle ne peut pas voter à moins d’être à nouveau invitée. Quitter le groupe pendant qu’un sondage est clôturé ne permet pas de conserver le droit de vote si ce sondage est rouvert.

Vous pouvez ajouter à nouveau les membres retirés au groupe ultérieurement. Lorsqu’ils rejoignent à nouveau le groupe, leur accès et leurs votes existants dans les sondages en cours sont rétablis.

<!-- translation-section: leaving-group -->

## Quitter le groupe

Pour quitter un groupe, ouvrez **Paramètres** sur la page du groupe et sélectionnez **Quitter le groupe**.

Quitter le groupe a les mêmes effets sur l’accès au groupe et à ses sous-groupes qu’un retrait par un administrateur du groupe.

![Action Quitter le groupe sur la page des paramètres de la coopérative Oatmilk](member_leave_group.png)

<!-- translation-section: set-title -->

## Définir un rôle

Le rôle indiqué pour un membre précise sa fonction dans le groupe ou l’organisation qu’il représente. Vous ou un administrateur du groupe pouvez définir ou modifier votre rôle en sélectionnant **Définir un rôle** dans le menu des actions à côté de votre nom dans l’onglet **Membres**.

![Action Définir un rôle dans le menu d’un membre](member_set_title.png)

Vous pouvez avoir des rôles différents dans les différents sous-groupes.

<!-- translation-section: member-email-addresses -->

## Adresses e-mail des membres

Seuls les administrateurs du groupe peuvent consulter les adresses e-mail des membres.

Pour consulter toutes les adresses e-mail des membres du groupe et de ses sous-groupes, [exportez les données du groupe](/en/user_manual/groups/data_export) au format CSV et ouvrez le fichier dans Microsoft Excel ou Google Sheets.

Vous pouvez également rechercher des membres par adresse e-mail dans l’onglet **Membres** pour trouver une personne précise et gérer son appartenance au groupe.
