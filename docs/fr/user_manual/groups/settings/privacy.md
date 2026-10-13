---
title: Confidentialité
source_revision: 3dad7e54d7f08f6d83af4b8adb6a408f1652ef7e
source_file: docs/en/user_manual/groups/settings/privacy.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-14'
sections:
  introduction: 4b491c663bfb5ea9
  open: 2802cda1461d3b19
  follow-an-open-group: e4a1b3ce35a974d0
  closed: fe4da2f032768bca
  secret: d0a9ea85448f9798
  how-people-join: 3840bb3403bb1788
  group-directory: a9a41ea389fb10ba
  visible-to-parent-group: 96b8595d3bc6ce4b
generated:
  introduction: 4863186cd3e805e2
  open: 0d9113a3fda4d343
  follow-an-open-group: 929a6682b62400f1
  closed: 1dd308772f2889c7
  secret: a8b75acd9144e9ba
  how-people-join: 2286c6f0ac6fd4ef
  group-directory: 7bf450758a066de4
  visible-to-parent-group: 721cc5ee30ba5582
title_source: 54a57c3147c49f33
title_generated: f19bb4113dafe7cf
needs_review:
  how-people-join: check the interface label "**Comment les personnes peuvent-elles rejoindre le groupe ?**" for "**How do people join?**"
---

<!-- translation-section: introduction -->

# Confidentialité du groupe

La confidentialité détermine qui peut trouver un groupe et qui peut lire son contenu. Depuis la page du groupe, ouvrez **Modifier les paramètres du groupe**, puis sélectionnez **Confidentialité**.

![Paramètres de confidentialité du groupe](group_privacy_settings.png#width-90)

Modifier la confidentialité affecte le contenu existant. Rendre un groupe parent privé fait également passer ses sous-groupes publics au paramètre **Visible pour le groupe parent** et rend leurs fils privés.

<!-- translation-section: open -->

## Public

Les groupes publics sont des espaces publics. Toute personne peut trouver le groupe et lire ses discussions, ses sondages et ses fichiers. La liste des membres reste visible uniquement par les membres.

<!-- translation-section: follow-an-open-group -->

### Suivre un groupe public

Les personnes peuvent suivre l’activité d’un groupe public sans le rejoindre. Le suivi ajoute l’activité non lue du groupe à leur e-mail récapitulatif pour qu’elles puissent la consulter quand elles le souhaitent. Suivre un groupe ne confère pas le statut de membre ni les droits de vote des membres, et ne déclenche pas de notifications immédiates.

Activez **Suivre les mises à jour** sur la page du groupe pour inclure ses discussions, commentaires, sondages et autres activités non lues dans les fils dans votre e-mail récapitulatif. Désactivez ce paramètre pour ne plus y inclure le groupe.

![Suivre les mises à jour d’un groupe public](group_follow_updates.png)

<!-- translation-section: closed -->

## Fermé

Toute personne peut trouver un groupe fermé et lire son nom et sa description. Les discussions, les sondages, les fichiers et la liste des membres sont réservés aux membres et aux invités.

<!-- translation-section: visible-to-parent-group -->

## Visible pour le groupe parent

Les membres du groupe parent et les membres du sous-groupe peuvent trouver le sous-groupe. Ses fils sont réservés aux membres du sous-groupe et aux invités.

<!-- translation-section: secret -->

## Secret

Les groupes secrets et leur contenu sont visibles uniquement par les personnes qui ont été invitées ou ajoutées. Les groupes secrets n’apparaissent pas dans l’annuaire public des groupes.

<!-- translation-section: how-people-join -->

## Comment rejoindre un groupe

Sous **Comment les personnes peuvent-elles rejoindre le groupe ?**, choisissez parmi les options disponibles :

| Option d’adhésion | Fonctionnement |
| --- | --- |
| Sans approbation | Les personnes peuvent rejoindre le groupe elles-mêmes |
| Approbation requise | Les personnes demandent à rejoindre le groupe et attendent une approbation |
| Sur invitation uniquement | Les personnes ont besoin d’une invitation pour rejoindre le groupe |

Lorsqu’une approbation est requise, les personnes sélectionnent **Rejoindre le groupe**, répondent à la question posée par le groupe et envoient une demande pour le rejoindre. Consultez [Inviter des personnes](/en/user_manual/groups/inviting_people#request-to-join-group) pour savoir comment configurer cette question, examiner les demandes et inviter directement des personnes.

<!-- translation-section: group-directory -->

## Annuaire des groupes

Les groupes parents publics et fermés peuvent figurer dans l’annuaire public des groupes pour permettre aux personnes de les découvrir. Les sous-groupes et les groupes secrets ne peuvent pas y figurer.
