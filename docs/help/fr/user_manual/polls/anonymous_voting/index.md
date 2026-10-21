---
title: Vote anonyme
source_revision: c6076258c3438c0dd6dc8fbf1fc0b0df47c0aeb5
source_file: docs/en/user_manual/polls/anonymous_voting/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-01'
sections:
  introduction: 2b9b7da01da020b3
  how-anonymous-voting-protects-voters: f2be8477636489af
  while-voting-is-open: dda23e517269b9cf
  votes-cannot-be-changed: 1e317297688ba902
  why-anonymous-votes-do-not-have-reasons: 39c1a8362550ae40
  results-and-exports: eb2429afd442dad2
  participation-verification: 87bc3647be4bbfb8
  reminders: 0afad473c90f2f03
  what-coordinators-and-administrators-can-see: 07faa9f646665b64
  limits-of-anonymous-voting: 912141560342d073
  questions: 60cc6f1a0163ec5d
  can-a-coordinator-see-how-i-voted: 574fc18f3a9871c3
  can-i-see-my-vote-after-submitting-it: c558e29729aed45f
  can-i-change-or-withdraw-my-vote: dd1a385fa8d225a5
  will-i-receive-an-email-confirming-my-vote: 8616fc9a0b9809ac
  does-a-public-poll-reveal-more-information: 27acfa7744a0790d
  is-anonymous-voting-suitable-for-every-election: d1b723178449c0da
generated:
  introduction: b97bdf2862e4ec7a
  how-anonymous-voting-protects-voters: d136bc2501a72059
  while-voting-is-open: 7218d0269e6c6bbc
  votes-cannot-be-changed: 47e26bade58623cb
  why-anonymous-votes-do-not-have-reasons: 0c4f22c307749d21
  results-and-exports: 3378fed87dc33ee5
  participation-verification: 8290bee2156868d5
  reminders: 0a68333c75993339
  what-coordinators-and-administrators-can-see: 4f8335d9f1a4f99c
  limits-of-anonymous-voting: '06209050d317de16'
  questions: 60cc6f1a0163ec5d
  can-a-coordinator-see-how-i-voted: c8866e96b45c008a
  can-i-see-my-vote-after-submitting-it: 8a63344a5172970d
  can-i-change-or-withdraw-my-vote: e083aa388aa0fc7f
  will-i-receive-an-email-confirming-my-vote: e731feb06a287566
  does-a-public-poll-reveal-more-information: 592c8c7da22ac750
  is-anonymous-voting-suitable-for-every-election: 145abfba67f35287
title_source: 1bc4567506ad4d51
title_generated: bbc8939bb7f73487
---

<!-- translation-section: introduction -->

# Vote anonyme

Le vote anonyme, également appelé vote à l’aveugle, sépare les données indiquant qui a voté des votes eux-mêmes. Après la clôture du sondage, toute personne pouvant voir les résultats peut voir qui a participé. Aucune personne utilisant Loomio ne peut relier un vote soumis à la personne qui l’a soumis.

Cette page explique les protections offertes par le vote anonyme, les informations conservées et les limites de cette garantie.

<!-- translation-section: how-anonymous-voting-protects-voters -->

## Comment le vote anonyme protège les électeurs

Un sondage anonyme conserve deux ensembles de données distincts :

| Données de participation | Votes soumis |
| --- | --- |
| Qui est autorisé à voter | Les options ou les notes sélectionnées |
| Qui a été invité, et par qui | Le sondage auquel le vote appartient |
| Si chaque personne autorisée à voter a voté | Aucun nom ni compte utilisateur |
| Aucune option ni note sélectionnée | Aucun lien vers les données de participation |

Aucun identifiant commun ne relie ces données. Les votes soumis ne contiennent pas non plus l’heure réelle de soumission, les informations sur l’invitation, les raisons écrites, les pièces jointes ni d’autres métadonnées qui pourraient aider à identifier un électeur.

Cette séparation est appliquée lors de l’enregistrement du vote. Elle ne repose pas uniquement sur le masquage des noms dans l’interface.

<!-- translation-section: while-voting-is-open -->

## Pendant que le vote est ouvert

Les résultats restent masqués pour tout le monde jusqu’à la clôture du sondage. Cela inclut les coordinateurs du sondage, les administrateurs du groupe et les administrateurs de l’instance qui utilisent l’application.

Lorsqu’une personne vote :

- son vote est enregistré sans son nom ni ses données de participation ;
- ses données de participation sont mises à jour pour indiquer qu’elle a voté ;
- aucun événement de vote, notification, e-mail, commentaire ni entrée d’activité n’est créé ;
- aucune copie de ses choix ne lui est renvoyée après la soumission ; et
- l’interface confirme uniquement que son vote a été enregistré.

Les données de participation ne conservent pas l’heure précise à laquelle la personne a voté. Les votes soumis ne sont pas classés par heure de soumission.

<!-- translation-section: votes-cannot-be-changed -->

## Les votes ne peuvent pas être modifiés

Chaque personne autorisée à voter peut voter une seule fois. Un vote anonyme soumis ne peut pas être consulté, modifié, retiré ni remplacé, même par un coordinateur ou un administrateur.

Permettre à une personne de retrouver ou de remplacer son vote nécessiterait un lien permanent entre cette personne et le vote. Le vote anonyme ne crée volontairement pas ce lien.

Vérifiez soigneusement vos choix avant de soumettre votre vote.

<!-- translation-section: why-anonymous-votes-do-not-have-reasons -->

## Pourquoi les votes anonymes ne comportent pas de raison

Les nouveaux votes anonymes ne peuvent pas inclure de raison écrite ni de pièce jointe. Les raisons peuvent contenir des noms, des informations personnelles, des particularités d’écriture, des mentions ou d’autres informations permettant d’identifier l’électeur. Elles rendraient aussi les votes individuels plus faciles à distinguer du résultat global.

Les participants peuvent toujours discuter du sondage dans son fil lorsque la discussion est disponible. Ces commentaires sont des contributions ordinaires à la discussion, associées au nom de leur auteur, et ne sont pas rattachés à un vote anonyme.

<!-- translation-section: results-and-exports -->

## Résultats et exports

Après la clôture du sondage, les résultats sont calculés à partir des votes séparés des données de participation et affichés sous forme de totaux et d’autres résultats agrégés pris en charge par le type de sondage.

L’application ne publie ni les identifiants des votes, ni leur ordre de soumission, ni leurs heures de soumission. Les exports de sondages contiennent des résultats agrégés plutôt qu’une ligne pour chaque vote anonyme, sauf qu’une élection STV clôturée peut être exportée au format BLT. Un export BLT contient les classements des candidats nécessaires au recomptage de l’élection, regroupés lorsque plusieurs bulletins présentent le même classement, sans l’identité des électeurs ni les métadonnées des bulletins.

Un sondage anonyme ne peut pas être rouvert après sa clôture.

<!-- translation-section: participation-verification -->

## Qui a participé

Après la clôture d’un sondage anonyme, toute personne pouvant voir ses résultats peut voir qui a participé. Personne ne peut voir cette information pendant que le vote est ouvert.

Sélectionnez **Voir les votes** pour consulter la liste. Elle indique toujours qui était autorisé à voter. Elle indique si chaque personne a voté uniquement lorsqu’un nombre suffisant de personnes a voté. Ce seuil correspond au quorum du sondage s’il en a un, sinon à la moitié des électeurs autorisés à voter, avec un minimum de trois votes dans tous les cas. La liste n’indique jamais comment une personne a voté, ni quand.

Les membres du groupe et les électeurs du sondage voient également quand chaque personne a rejoint le groupe et qui l’a invitée. Les administrateurs du groupe voient aussi les adresses e-mail pour distinguer les personnes qui portent le même nom.

Comme toute personne pouvant voir les résultats peut voir qui a voté, un résultat unanime peut révéler comment les personnes ont voté. Par exemple, si tous les votes sont Accord, toutes les personnes qui ont voté ont exprimé leur accord.

Les coordinateurs peuvent ajouter des personnes autorisées à voter tant que le vote reste ouvert, y compris après que d’autres personnes ont voté. Les électeurs déjà présents ne peuvent pas être retirés d’un sondage anonyme.

<!-- translation-section: reminders -->

## Rappels

Pour un sondage anonyme d’une durée d’au moins 24 heures, les personnes autorisées à voter qui n’ont pas voté reçoivent un rappel automatique au cours des dernières 24 heures.

Les destinataires du rappel sont sélectionnés uniquement à partir des données de participation. Cette sélection n’examine pas les votes soumis et ne crée aucun lien avec eux. Si la date limite change, la vérification horaire des rappels utilise la date limite actuelle sans conserver de rappel programmé séparément pour le sondage.

Les sondages dont la durée totale de vote est inférieure à 24 heures n’envoient pas ce rappel automatique.

<!-- translation-section: what-coordinators-and-administrators-can-see -->

## Ce que les coordinateurs et les administrateurs peuvent voir

Dans l’application, un coordinateur de sondage, un administrateur de groupe ou un administrateur d’instance peut avoir accès aux informations suivantes :

- le sondage et ses électeurs autorisés à voter ;
- si chaque personne autorisée à voter a voté, lorsque son rôle permet cet accès et qu’un nombre suffisant de personnes a voté ; et
- les résultats agrégés après la clôture du sondage.

Les fonctionnalités de l’application ne leur permettent pas de voir :

- quels choix appartiennent à une personne ;
- les votes individuels ou les tendances de vote individuelles ;
- quand un vote particulier a été soumis ; ou
- une raison, une pièce jointe, un événement ou une notification associés à un vote soumis.

<!-- translation-section: limits-of-anonymous-voting -->

## Limites du vote anonyme

Ces protections empêchent les utilisateurs de l’application de relier un vote soumis à son électeur. Elles ne constituent pas une protection cryptographique contre un opérateur pouvant examiner la base de données, les sauvegardes, les journaux du serveur, la mémoire des processus, le trafic réseau ou une version modifiée de l’application.

Le résultat lui-même peut aussi révéler des informations. Un petit nombre d’électeurs, un résultat unanime, une combinaison distinctive de choix ou des informations partagées en dehors du sondage peuvent faciliter la déduction des choix d’une personne. Les électeurs peuvent aussi choisir de s’identifier dans la discussion, indépendamment du vote qu’ils ont soumis.

Tenez compte du nombre d’électeurs et du caractère sensible de la décision pour déterminer si le vote anonyme au niveau de l’application convient.

<!-- translation-section: questions -->

## Questions

<!-- translation-section: can-a-coordinator-see-how-i-voted -->

### Quelqu’un peut-il voir comment j’ai voté ?

Non. Dès qu’un nombre suffisant de personnes a voté, les personnes pouvant voir les résultats peuvent voir si vous avez voté. Personne ne peut vous relier à un vote soumis par l’intermédiaire de l’application. Jusque-là, le fait que vous ayez voté ou non reste masqué.

<!-- translation-section: can-i-see-my-vote-after-submitting-it -->

### Puis-je voir mon vote après l’avoir soumis ?

Non. L’application confirme que votre vote a été enregistré, puis efface vos choix de l’interface de vote. Elle ne peut pas retrouver votre vote sans créer le lien que le vote anonyme vise à éviter.

<!-- translation-section: can-i-change-or-withdraw-my-vote -->

### Puis-je modifier ou retirer mon vote ?

Non. Aucun lien ne permet à l’application d’identifier le vote soumis à modifier ou à supprimer.

<!-- translation-section: will-i-receive-an-email-confirming-my-vote -->

### Vais-je recevoir un e-mail confirmant mon vote ?

Non. Le vote affiche uniquement une confirmation à l’écran et met à jour votre enregistrement de participation. Il n’envoie pas d’e-mail de confirmation et ne crée ni notification ni événement d’activité.

<!-- translation-section: does-a-public-poll-reveal-more-information -->

### Un sondage public révèle-t-il davantage d’informations ?

Après la clôture d’un sondage public, tout le monde peut voir ses résultats et qui y a participé. Les votes individuels et les détails concernant l’adhésion et les invitations ne sont pas visibles.

<!-- translation-section: is-anonymous-voting-suitable-for-every-election -->

### Le vote anonyme convient-il à toutes les élections ?

Non. Il sépare les identités des votes au sein de l’application. Les décisions nécessitant une protection contre les opérateurs du système ou des élections cryptographiques vérifiables de manière indépendante exigent un système conçu pour répondre à ces besoins.
