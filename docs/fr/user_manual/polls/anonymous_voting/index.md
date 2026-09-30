---
title: Vote anonyme
source_revision: 7a01b0fd7d7df0c4bca327a916b01b12e62b967f
source_file: docs/user_manual/polls/anonymous_voting/index.md
translated:
  provider: codex/gpt-6-sol
  'on': '2026-09-29'
sections:
  introduction: d5c276b2785919c3
  how-anonymous-voting-protects-voters: f2be8477636489af
  while-voting-is-open: dda23e517269b9cf
  votes-cannot-be-changed: 1e317297688ba902
  why-anonymous-votes-do-not-have-reasons: 39c1a8362550ae40
  results-and-exports: eb2429afd442dad2
  participation-verification: cdaa1f5c3ca1e179
  reminders: 0afad473c90f2f03
  what-coordinators-and-administrators-can-see: 51460c8a6b663aba
  limits-of-anonymous-voting: 912141560342d073
  questions: 60cc6f1a0163ec5d
  can-a-coordinator-see-how-i-voted: 3dd2c9e6d06debda
  can-i-see-my-vote-after-submitting-it: c558e29729aed45f
  can-i-change-or-withdraw-my-vote: dd1a385fa8d225a5
  will-i-receive-an-email-confirming-my-vote: 8616fc9a0b9809ac
  does-a-public-poll-reveal-more-information: 2ba76a1748304f96
  is-anonymous-voting-suitable-for-every-election: d1b723178449c0da
generated:
  introduction: 6ed1e44e4a1ffe99
  how-anonymous-voting-protects-voters: c4e8af91a5bfadc2
  while-voting-is-open: 6114745dc05f4347
  votes-cannot-be-changed: 11fe346c4be49745
  why-anonymous-votes-do-not-have-reasons: a1a0195c20d53a42
  results-and-exports: 195248b5718ed9e3
  participation-verification: 95510302509e2980
  reminders: bde6d44c58193f80
  what-coordinators-and-administrators-can-see: e7d6d709f604c90e
  limits-of-anonymous-voting: 38c1e7744460be65
  questions: 60cc6f1a0163ec5d
  can-a-coordinator-see-how-i-voted: 070ec3aa7aff58ce
  can-i-see-my-vote-after-submitting-it: 531adb0ff94594a4
  can-i-change-or-withdraw-my-vote: c44f10ca4f1d38f2
  will-i-receive-an-email-confirming-my-vote: 750f2fd2f3fdbe8c
  does-a-public-poll-reveal-more-information: 817164697a3ca60f
  is-anonymous-voting-suitable-for-every-election: 7a9e083d5029d25f
title_source: 1bc4567506ad4d51
title_generated: bbc8939bb7f73487
---

<!-- translation-section: introduction -->

# Vote anonyme

Le vote anonyme, aussi appelé vote à bulletin secret, sépare les informations sur la participation des votes eux-mêmes. Les coordinateurs du sondage peuvent voir qui avait le droit de voter et, dès qu’au moins trois personnes ont voté, vérifier la participation. Les utilisateurs de l’application ne peuvent pas relier un vote enregistré à la personne qui l’a exprimé.

Cette page explique les protections offertes par le vote anonyme, les informations conservées et les limites de cette garantie.

<!-- translation-section: how-anonymous-voting-protects-voters -->

## Comment le vote anonyme protège les votants

Un sondage anonyme conserve deux ensembles de données distincts :

| Données de participation | Votes enregistrés |
| --- | --- |
| Les personnes ayant le droit de voter | Les options choisies ou les notes attribuées |
| Les personnes invitées et l’auteur de chaque invitation | Le sondage auquel appartient le vote |
| Le fait que chaque personne ayant le droit de voter ait voté ou non | Aucun nom ni compte utilisateur |
| Aucune option choisie ni note attribuée | Aucun lien vers une donnée de participation |

Aucun identifiant commun ne relie ces données. Les votes enregistrés ne contiennent pas non plus l’heure exacte de leur envoi, les informations d’invitation, les raisons écrites, les pièces jointes ou d’autres métadonnées susceptibles d’identifier un votant.

Cette séparation est appliquée lors de l’enregistrement du vote. Elle ne repose pas uniquement sur le masquage des noms dans l’interface.

<!-- translation-section: while-voting-is-open -->

## Pendant que le vote est ouvert

Les résultats restent masqués pour tout le monde jusqu’à la clôture du sondage. Cela inclut les coordinateurs du sondage, les administrateurs du groupe et les administrateurs de l’instance qui utilisent l’application.

Lorsqu’une personne vote :

- son vote est enregistré sans son nom ni ses données de participation ;
- ses données de participation indiquent qu’elle a voté ;
- aucun événement de vote, notification, e-mail, commentaire ou entrée d’activité n’est créé ;
- aucune copie de ses choix ne lui est renvoyée après l’envoi ; et
- l’interface confirme uniquement que son vote a été enregistré.

Les données de participation ne conservent pas l’heure précise à laquelle la personne a voté. Les votes enregistrés ne sont pas classés par ordre d’envoi.

<!-- translation-section: votes-cannot-be-changed -->

## Les votes ne peuvent pas être modifiés

Chaque personne ayant le droit de voter ne peut voter qu’une fois. Un vote anonyme enregistré ne peut pas être consulté, modifié, retiré ou remplacé, même par un coordinateur ou un administrateur.

Permettre à une personne de retrouver ou de remplacer son vote nécessiterait un lien permanent entre cette personne et son vote. Le vote anonyme ne crée pas ce lien.

Vérifiez attentivement vos choix avant d’envoyer votre vote.

<!-- translation-section: why-anonymous-votes-do-not-have-reasons -->

## Pourquoi les votes anonymes ne comportent pas de raisons

Les nouveaux votes anonymes ne peuvent contenir ni raison écrite ni pièce jointe. Une raison peut contenir des noms, des détails personnels, des habitudes d’écriture, des mentions ou d’autres informations permettant d’identifier la personne qui a voté. Elle peut aussi rendre un vote individuel plus facile à distinguer du résultat global.

Les participants peuvent toujours parler du sondage dans son fil de discussion, lorsque la discussion est disponible. Ces commentaires sont des contributions ordinaires portant le nom de leur auteur. Ils ne sont pas associés à un vote anonyme.

<!-- translation-section: results-and-exports -->

## Résultats et exportations

Après la clôture du sondage, les résultats sont calculés à partir des votes séparés des données de participation. Ils sont affichés sous forme de totaux et d’autres résultats globaux selon le type de sondage.

L’application ne publie ni les identifiants des votes, ni leur ordre d’envoi, ni l’heure à laquelle ils ont été envoyés. Les exportations de sondages contiennent des résultats globaux plutôt qu’une ligne par vote anonyme. Une élection STV clôturée peut toutefois être exportée au format BLT. Cette exportation contient les classements des candidats nécessaires pour recompter les voix. Les bulletins ayant le même classement sont regroupés, sans identité des votants ni métadonnées des bulletins.

Un sondage anonyme ne peut pas être rouvert après sa clôture.

<!-- translation-section: participation-verification -->

## Vérification de la participation

Les coordinateurs du sondage peuvent consulter les données de participation nominatives. Elles indiquent toujours qui avait le droit de voter. Dès qu’au moins trois personnes ont voté, elles indiquent également si chaque personne a voté, mais jamais ce qu’elle a choisi. Si un sondage se termine avec moins de trois votes, les informations sur la participation restent masquées.

Les autres participants ne peuvent pas consulter ces données de participation nominatives. L’accès aux résultats du sondage ne donne pas accès aux données de participation.

Les coordinateurs peuvent ajouter des personnes ayant le droit de voter tant que le vote reste ouvert, y compris après que d’autres personnes ont voté. Les personnes ayant déjà voté ne peuvent pas être retirées d’un sondage anonyme.

<!-- translation-section: reminders -->

## Rappels

Pour un sondage anonyme qui dure au moins 24 heures, les personnes ayant le droit de voter qui ne l’ont pas encore fait reçoivent un rappel automatique au cours des dernières 24 heures.

Les destinataires du rappel sont déterminés uniquement à partir des données de participation. Le rappel ne consulte pas les votes enregistrés et ne crée aucun lien avec eux. Si l’échéance change, la vérification horaire des rappels utilise la nouvelle échéance, sans conserver de rappel programmé séparément pour le sondage.

Les sondages dont la période de vote totale est inférieure à 24 heures n’envoient pas ce rappel automatique.

<!-- translation-section: what-coordinators-and-administrators-can-see -->

## Ce que peuvent voir les coordinateurs et les administrateurs

Dans l’application, un coordinateur du sondage, un administrateur du groupe ou un administrateur de l’instance peut, selon ses droits, voir :

- le sondage et les personnes ayant le droit de voter ;
- si chaque personne ayant le droit de voter a voté, lorsque son rôle lui donne accès à cette information et qu’au moins trois personnes ont voté ; et
- les résultats globaux après la clôture du sondage.

Les fonctionnalités de l’application ne leur permettent pas de voir :

- les choix d’une personne ;
- les votes individuels ou les tendances de vote ;
- le moment où un vote particulier a été envoyé ; ou
- une raison, une pièce jointe, un événement ou une notification associé à un vote enregistré.

<!-- translation-section: limits-of-anonymous-voting -->

## Limites du vote anonyme

Ces protections empêchent les utilisateurs de l’application de relier un vote enregistré à la personne qui l’a exprimé. Elles ne constituent pas une protection cryptographique contre un opérateur capable d’inspecter la base de données, les sauvegardes, les journaux du serveur, la mémoire des processus, le trafic réseau ou une version modifiée de l’application.

Le résultat lui-même peut aussi révéler des informations. Un petit nombre de votants, un résultat unanime, une combinaison de choix distinctive ou des informations partagées hors du sondage peuvent faciliter la déduction des choix d’une personne. Les votants peuvent également choisir de révéler leur identité dans une discussion, en dehors de leur vote enregistré.

Pour déterminer si le vote anonyme proposé par l’application convient, tenez compte du nombre de personnes appelées à voter et de la sensibilité de la décision.

<!-- translation-section: questions -->

## Questions

<!-- translation-section: can-a-coordinator-see-how-i-voted -->

### Une personne qui coordonne le sondage peut-elle voir mon vote ?

Non. Dès qu’au moins trois personnes ont voté, la personne qui coordonne le sondage peut vérifier si vous avez voté, mais l’application ne lui permet pas d’associer votre nom à un vote. En dessous de ce seuil, votre participation reste masquée.

<!-- translation-section: can-i-see-my-vote-after-submitting-it -->

### Puis-je consulter mon vote après l’avoir envoyé ?

Non. L’application confirme que votre vote a été enregistré, puis retire vos choix de l’interface de vote. Elle ne peut pas retrouver votre vote sans créer le lien que le vote anonyme vise à éviter.

<!-- translation-section: can-i-change-or-withdraw-my-vote -->

### Puis-je modifier ou retirer mon vote ?

Non. Aucun lien ne permet à l’application de déterminer quel vote modifier ou retirer.

<!-- translation-section: will-i-receive-an-email-confirming-my-vote -->

### Vais-je recevoir un courriel confirmant mon vote ?

Non. Lorsque vous votez, l’application affiche une confirmation à l’écran et met à jour votre dossier de participation. Elle n’envoie pas de courriel de confirmation et ne crée ni notification ni événement d’activité.

<!-- translation-section: does-a-public-poll-reveal-more-information -->

### Un sondage public révèle-t-il davantage d’informations ?

L’accès public peut permettre de consulter le sondage et ses résultats agrégés après sa clôture. Il ne donne pas accès aux dossiers de participation nominatifs ni aux votes anonymes individuels.

<!-- translation-section: is-anonymous-voting-suitable-for-every-election -->

### Le vote anonyme convient-il à toutes les élections ?

Non. Il sépare les identités des votes au sein de l’application. Les décisions qui exigent une protection contre les personnes qui exploitent le système ou une vérification cryptographique indépendante nécessitent un système conçu pour répondre à ces exigences.
