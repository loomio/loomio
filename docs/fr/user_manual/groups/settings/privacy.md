---
title: Confidentialité
source_revision: cd2e1e63e611688362e80009f50b8ed25025ba8b
source_file: docs/en/user_manual/groups/settings/privacy.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-07'
sections:
  introduction: 72b58ba22851f914
  open: 1727e8f20fe92fb2
  follow-an-open-group: e4a1b3ce35a974d0
  closed: 53c3d50151a2115b
  secret: fcb55fcb64d44881
  how-people-join: f61d4f7e0f88106a
  group-directory: 4ef3023e3cf4efdf
  visible-to-parent-group: a9a3ece6458f080e
generated:
  introduction: 5f81dd9da549011a
  open: bcd6e71779cb2a69
  follow-an-open-group: 929a6682b62400f1
  closed: f166864aa07ff380
  secret: 470dbecee618f7a0
  how-people-join: 13eb546920e16b1a
  group-directory: 2410a83502c18fbd
  visible-to-parent-group: 8427be659ee8f344
title_source: 54a57c3147c49f33
title_generated: f19bb4113dafe7cf
---

<!-- translation-section: introduction -->

# Confidentialité du groupe

La confidentialité détermine qui peut trouver un groupe et qui peut lire son contenu. Depuis la page du groupe, ouvrez **Modifier les paramètres du groupe**, puis sélectionnez **Confidentialité**.

![Paramètres de confidentialité du groupe](group_privacy_settings.png#width-90)

Modifier la confidentialité peut rendre visible ou masquer le contenu existant du groupe, pas seulement le contenu créé par la suite. Choisissez le paramètre le plus restrictif qui reste compatible avec l’objectif du groupe.

<!-- translation-section: open -->

## Public

Les groupes publics sont des espaces publics. Toute personne peut trouver le groupe et lire ses discussions, ses sondages et ses fichiers. La liste des membres reste visible uniquement par les membres.

Les groupes publics peuvent permettre aux personnes de rejoindre le groupe immédiatement, exiger une approbation ou rester accessibles uniquement sur invitation.

<!-- translation-section: follow-an-open-group -->

### Suivre un groupe public

Les personnes peuvent suivre l’activité d’un groupe public sans le rejoindre. Le suivi ajoute l’activité non lue du groupe à leur e-mail récapitulatif pour qu’elles puissent la consulter quand elles le souhaitent. Suivre un groupe ne confère pas le statut de membre ni les droits de vote des membres, et ne déclenche pas de notifications immédiates.

Activez **Suivre les mises à jour** sur la page du groupe pour inclure ses discussions, commentaires, sondages et autres activités non lues dans les fils dans votre e-mail récapitulatif. Désactivez ce paramètre pour ne plus y inclure le groupe.

![Suivre les mises à jour d’un groupe public](group_follow_updates.png)

<!-- translation-section: closed -->

## Fermé

Toute personne peut trouver un groupe fermé et lire son nom et sa description. Les discussions, les sondages, les fichiers et la liste des membres sont réservés aux membres et aux invités.

Les groupes parents fermés peuvent permettre aux personnes de demander à devenir membres ou rester accessibles uniquement sur invitation. Ils ne peuvent pas permettre de rejoindre le groupe immédiatement sans approbation.

Les sous-groupes fermés peuvent aussi permettre à toute personne de les rejoindre sans approbation. Pour réserver leur découverte et l’adhésion immédiate aux membres du groupe parent, sélectionnez plutôt **Visible pour le groupe parent**.

Un sous-groupe fermé peut, si cette option est activée, permettre aux membres du groupe parent de lire ses discussions sans rejoindre le sous-groupe.

<!-- translation-section: visible-to-parent-group -->

## Visible pour le groupe parent

Ce paramètre permet aux membres du groupe parent de trouver le sous-groupe tout en réservant ses fils aux membres du sous-groupe et aux invités. Les personnes qui ne font partie d’aucun des deux groupes ne peuvent pas le trouver, même lorsque le groupe parent est public.

Sélectionnez **Visible pour le groupe parent**, puis **Les membres de [groupe parent] peuvent rejoindre le sous-groupe sans approbation** pour permettre aux membres du groupe parent de le rejoindre eux-mêmes. Ils deviennent alors membres du sous-groupe et ont notamment accès à ses fils privés. L’adhésion avec approbation ou uniquement sur invitation est également possible.

Le sous-groupe conserve cette visibilité lorsque le groupe parent devient public. Si le groupe parent devient privé, ses sous-groupes publics deviennent **Visible pour le groupe parent** et leurs fils deviennent privés. Les sous-groupes secrets restent secrets. Les sous-groupes existants auparavant indiqués comme fermés au sein d’un groupe parent privé affichent désormais **Visible pour le groupe parent**, sans changement de leurs accès existants.

Pour permettre aux membres du groupe parent de lire les fils privés avant de rejoindre le sous-groupe, activez **Les membres de [groupe parent] peuvent voir les fils privés** dans **Permissions**. Cela leur accorde un accès en lecture, sans leur donner le statut de membre du sous-groupe ni le droit de vote.

<!-- translation-section: secret -->

## Secret

Les groupes secrets et leur contenu sont visibles uniquement par les personnes qui ont été invitées ou ajoutées. Il est possible de devenir membre uniquement sur invitation. Les groupes secrets n’apparaissent pas dans l’annuaire public des groupes.

Un groupe parent secret ne peut contenir que des sous-groupes **Visible pour le groupe parent** ou **Secret**. Ses sous-groupes ne peuvent pas être ouverts ou fermés.

<!-- translation-section: how-people-join -->

## Comment rejoindre un groupe

La confidentialité détermine les options disponibles pour rejoindre un groupe :

| Confidentialité du groupe | Options disponibles pour rejoindre le groupe |
| --- | --- |
| **Ouvert** | Toute personne peut rejoindre le groupe, demander une approbation ou rejoindre le groupe uniquement sur invitation |
| **Groupe parent fermé** | Demander une approbation ou rejoindre le groupe uniquement sur invitation |
| **Sous-groupe fermé** | Toute personne peut rejoindre le groupe, demander une approbation ou rejoindre le groupe uniquement sur invitation |
| **Visible pour le groupe parent** | Les membres du groupe parent peuvent rejoindre le sous-groupe, demander une approbation ou rejoindre le sous-groupe uniquement sur invitation |
| **Secret** | Sur invitation uniquement |

L’adhésion immédiate dépend de la visibilité du groupe. Dans un sous-groupe public, toute personne peut rejoindre le sous-groupe. Dans un sous-groupe **Visible pour le groupe parent**, les membres du groupe parent peuvent le rejoindre. Les membres peuvent quitter le sous-groupe et le rejoindre à nouveau tant qu’ils remplissent les conditions d’adhésion. Modifier les modalités d’adhésion ne change pas qui peut lire les fils privés avant de rejoindre le groupe.

Lorsqu’une approbation est requise, les personnes sélectionnent **Rejoindre le groupe**, répondent à la question posée par le groupe et envoient une demande pour le rejoindre. Consultez [Inviter des personnes](/en/user_manual/groups/inviting_people#request-to-join-group) pour savoir comment configurer cette question, examiner les demandes et inviter directement des personnes.

<!-- translation-section: group-directory -->

## Annuaire des groupes

Les groupes parents publics et fermés peuvent figurer dans l’annuaire public des groupes pour permettre aux personnes de les découvrir. L’inscription dans l’annuaire ne change pas qui peut lire le contenu du groupe ou en devenir membre. Les sous-groupes et les groupes secrets ne peuvent pas y figurer.
