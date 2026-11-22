---
title: Vote anonyme
source_revision: ad97f553685def918a7d6e47ac5b66773de2dba8
source_file: docs/help/en/user_manual/polls/anonymous_voting/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-11-22'
sections:
  introduction: ffcecd2f4297c47d
  how-anonymous-voting-protects-voters: 3b757a1b4a7bda96
  while-voting-is-open: aafc698ee8108194
  votes-cannot-be-changed: 3a99e6c3f48e10ee
  why-anonymous-votes-do-not-have-reasons: 4027d6c1fbf4d29c
  results-and-exports: 5c10ab43a5f890b4
  participation-verification: e77ece0fc0d6cd73
  reminders: f711a180ae7c948f
  what-coordinators-and-administrators-can-see: d873cd48677fc324
  limits-of-anonymous-voting: 9ab54b74a4716e19
  questions: 60cc6f1a0163ec5d
  can-a-coordinator-see-how-i-voted: bfa1baf48f41cdd1
  can-i-see-my-vote-after-submitting-it: 435010e0c2ecf488
  can-i-change-or-withdraw-my-vote: 676d5401bf4d73cc
  will-i-receive-an-email-confirming-my-vote: 9660f10e8ffb9f9c
  does-a-public-poll-reveal-more-information: '087defb00bb8b99f'
  is-anonymous-voting-suitable-for-every-election: 9fae56c0661f0ec9
generated:
  introduction: 7c5add0526306dfd
  how-anonymous-voting-protects-voters: f48491f6f7767d7a
  while-voting-is-open: 2b83ffe132ddeec8
  votes-cannot-be-changed: 3130b8e1beb15f8b
  why-anonymous-votes-do-not-have-reasons: 7dd262513b424d8f
  results-and-exports: 574d9c69bf05d66d
  participation-verification: bdd7a98bf1b3af3e
  reminders: e367192e17329ac7
  what-coordinators-and-administrators-can-see: 2e96b0617400c5ff
  limits-of-anonymous-voting: c836d695252a0e0b
  questions: 60cc6f1a0163ec5d
  can-a-coordinator-see-how-i-voted: 1e120428ac687250
  can-i-see-my-vote-after-submitting-it: e6719ee4b76f2fe7
  can-i-change-or-withdraw-my-vote: 0576c693fa139f67
  will-i-receive-an-email-confirming-my-vote: 92bc5875cd2bf368
  does-a-public-poll-reveal-more-information: 592c8c7da22ac750
  is-anonymous-voting-suitable-for-every-election: 132880eaa2e525d7
title_source: 1bc4567506ad4d51
title_generated: bbc8939bb7f73487
---

<!-- translation-section: introduction -->

# Vote anonyme

Le vote anonyme, également appelé vote à l’aveugle, sépare les données indiquant qui a voté des votes eux-mêmes. Après la clôture du sondage, toute personne pouvant voir les résultats peut voir qui a participé, mais aucune personne utilisant Loomio ne peut relier un vote à la personne qui l’a soumis.

Cette page explique le fonctionnement du vote anonyme, les informations conservées et les limites de cette protection.

<!-- translation-section: how-anonymous-voting-protects-voters -->

## Comment le vote anonyme protège les électeurs

Un sondage anonyme conserve deux ensembles de données distincts :

| Données de participation | Votes soumis |
| --- | --- |
| Qui est autorisé à voter | Les options ou les notes sélectionnées |
| Qui a été invité, et par qui | Le sondage auquel le vote appartient |
| Si chaque personne autorisée à voter a voté | Aucun nom ni compte utilisateur |
| Aucune option ni note sélectionnée | Aucun lien vers les données de participation |

Aucun identifiant commun ne relie ces données. Les votes soumis ne contiennent pas non plus les heures de soumission, les informations sur les invitations, les raisons des votes, les pièces jointes ni d’autres métadonnées qui pourraient identifier un électeur.

Cette séparation est appliquée lors de l’enregistrement du vote ; elle ne repose pas simplement sur le masquage des noms dans l’interface.

<!-- translation-section: while-voting-is-open -->

## Pendant que le vote est ouvert

Les résultats restent masqués pour tout le monde jusqu’à la clôture du sondage, y compris les administrateurs du fil, les administrateurs du groupe et les administrateurs de l’instance.

Lorsqu’une personne vote :

- son vote est enregistré sans son nom ni ses données de participation ;
- ses données de participation sont mises à jour pour indiquer qu’elle a voté ;
- aucun événement de vote, notification, e-mail, commentaire ni entrée d’activité n’est créé ;
- aucune copie de ses choix ne lui est renvoyée après la soumission ; et
- l’écran confirme uniquement que son vote a été enregistré.

Les données de participation ne conservent pas l’heure précise à laquelle une personne a voté, et les votes soumis ne sont pas classés par heure de soumission.

<!-- translation-section: votes-cannot-be-changed -->

## Les votes ne peuvent pas être modifiés

Chaque personne autorisée à voter peut voter une seule fois. Un vote anonyme soumis ne peut pas être consulté, modifié, retiré ni remplacé, même par un administrateur.

Permettre à une personne de retrouver ou de remplacer son vote nécessiterait un lien entre cette personne et son vote, ce que le vote anonyme évite volontairement.

Vérifiez soigneusement vos choix avant de soumettre votre vote.

<!-- translation-section: why-anonymous-votes-do-not-have-reasons -->

## Pourquoi les votes anonymes ne comportent pas de raison

Les votes anonymes ne peuvent pas inclure de raison du vote ni de pièce jointe. Les raisons peuvent contenir des noms, des informations personnelles, des particularités d’écriture ou des mentions permettant d’identifier l’électeur, et pourraient rendre les votes individuels plus faciles à distinguer dans les résultats.

Les participants peuvent toujours discuter du sondage dans son fil. Ces commentaires sont des contributions ordinaires associées au nom de leur auteur et ne sont pas liés à un vote anonyme.

<!-- translation-section: results-and-exports -->

## Résultats et exports

Après la clôture du sondage, Loomio calcule les résultats à partir des votes séparés des données de participation et affiche les totaux correspondant au type de sondage.

Loomio ne publie ni les identifiants des votes, ni leur ordre de soumission, ni leurs heures de soumission. Les exports de sondages contiennent uniquement des résultats agrégés plutôt qu’une ligne pour chaque vote. La seule exception est une élection STV clôturée, qui peut être exportée au format BLT pour un recomptage. Un export BLT présente les classements des candidats, regroupés lorsque plusieurs bulletins présentent le même classement, sans l’identité des électeurs ni les métadonnées des bulletins.

Un sondage anonyme ne peut pas être rouvert après sa clôture.

<!-- translation-section: participation-verification -->

## Qui a participé

Après la clôture d’un sondage anonyme, toute personne pouvant voir ses résultats peut voir qui a participé. Personne ne peut voir cette information pendant que le vote est ouvert.

Sélectionnez **Voir les votes** pour consulter la liste. Elle indique toujours qui était autorisé à voter et n’indique jamais comment ni quand une personne a voté. Elle indique si chaque personne a voté uniquement lorsqu’un nombre suffisant de personnes a participé : au moins le quorum du sondage s’il est défini, sinon au moins la moitié des électeurs autorisés à voter, avec un minimum de trois votes dans tous les cas.

Les membres du groupe et les électeurs du sondage voient également quand chaque personne a rejoint le groupe et qui l’a invitée. Les administrateurs du groupe voient aussi les adresses e-mail pour distinguer les personnes qui portent le même nom.

Comme toute personne pouvant voir les résultats peut voir qui a voté, un résultat allant dans un seul sens peut révéler comment les personnes ont voté. Par exemple, si tous les votes sont Accord, toutes les personnes qui ont voté ont exprimé leur accord.

Les administrateurs peuvent ajouter des personnes autorisées à voter tant que le vote reste ouvert, y compris après que d’autres personnes ont voté. Les électeurs déjà présents ne peuvent pas être retirés d’un sondage anonyme.

<!-- translation-section: reminders -->

## Rappels

Pour un sondage anonyme d’une durée d’au moins 24 heures, les personnes autorisées à voter qui n’ont pas voté reçoivent un rappel automatique au cours des dernières 24 heures.

Loomio sélectionne les destinataires uniquement à partir des données de participation, sans examiner les votes soumis.

Les sondages dont la durée de vote est inférieure à 24 heures n’envoient pas ce rappel automatique.

<!-- translation-section: what-coordinators-and-administrators-can-see -->

## Ce que les administrateurs peuvent voir

Dans l’application, un administrateur de fil, un administrateur de groupe ou un administrateur d’instance peut avoir accès aux informations suivantes :

- le sondage et ses électeurs autorisés à voter ;
- si chaque personne autorisée à voter a voté, lorsque son rôle permet cet accès et qu’un nombre suffisant de personnes a voté ; et
- les résultats agrégés après la clôture du sondage.

L’application ne leur permet pas de voir :

- quels choix appartiennent à une personne ;
- les votes individuels ou les tendances de vote individuelles ;
- quand un vote a été soumis ; ou
- une raison du vote, une pièce jointe, un événement ou une notification liés à un vote.

<!-- translation-section: limits-of-anonymous-voting -->

## Limites du vote anonyme

Le vote anonyme empêche les utilisateurs de Loomio de relier un vote à un électeur. Il ne constitue pas une protection cryptographique contre un opérateur de serveur pouvant examiner la base de données, les sauvegardes, les journaux du serveur, la mémoire des processus, le trafic réseau ou du code modifié.

Les résultats eux-mêmes peuvent aussi donner des indices. Un petit groupe, un vote unanime, une combinaison unique de choix ou des commentaires partagés en dehors du sondage peuvent faciliter la déduction du vote d’une personne.

Tenez compte de la taille du groupe et du caractère sensible de la décision avant de vous appuyer sur le vote anonyme au niveau de l’application.

<!-- translation-section: questions -->

## Questions

<!-- translation-section: can-a-coordinator-see-how-i-voted -->

### Quelqu’un peut-il voir comment j’ai voté ?

Non. Aucune personne utilisant Loomio ne peut vous relier à votre vote. Dès qu’un nombre suffisant de personnes a voté, toute personne pouvant voir les résultats peut voir si vous avez participé. Avant que ce seuil soit atteint, même le fait que vous ayez voté ou non reste masqué.

<!-- translation-section: can-i-see-my-vote-after-submitting-it -->

### Puis-je voir mon vote après l’avoir soumis ?

Non. Loomio confirme que votre vote a été enregistré et efface vos choix de l’écran. Il ne peut pas retrouver votre vote sans créer le lien que le vote anonyme évite.

<!-- translation-section: can-i-change-or-withdraw-my-vote -->

### Puis-je modifier ou retirer mon vote ?

Non. Comme il n’existe aucun lien entre vous et votre vote, Loomio ne peut pas identifier le vote à modifier ou à supprimer.

<!-- translation-section: will-i-receive-an-email-confirming-my-vote -->

### Vais-je recevoir un e-mail confirmant mon vote ?

Non. Le vote affiche uniquement une confirmation à l’écran et met à jour votre enregistrement de participation. Il n’envoie pas d’e-mail et ne crée ni notification ni entrée dans l’activité.

<!-- translation-section: does-a-public-poll-reveal-more-information -->

### Un sondage public révèle-t-il davantage d’informations ?

Après la clôture d’un sondage public, tout le monde peut voir ses résultats et qui y a participé. Les votes individuels et les détails concernant l’adhésion et les invitations ne sont pas visibles.

<!-- translation-section: is-anonymous-voting-suitable-for-every-election -->

### Le vote anonyme convient-il à toutes les élections ?

Non. Il sépare les électeurs des votes au sein de l’application. Les élections nécessitant une protection contre les opérateurs du serveur ou une vérification cryptographique indépendante exigent un système conçu pour répondre à ces besoins.
