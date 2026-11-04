---
title: Gérer les électeurs
source_revision: adca14fde066a1ed3f6b2bb163d402235efbc709
source_file: docs/help/en/user_manual/polls/manage_voters/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-29'
sections:
  introduction: ea21036eb694c27f
  invite-people-to-vote-in-a-poll: c087ce6e0173270f
  invite-guests-or-experts: c6e4d0e0811de6f2
  engage-people-while-a-poll-is-running: d0eb90b4b53003bc
  add-voters-to-the-poll: 621bd4bf8ed67895
  remove-people-from-the-poll: be96ad95169a79a3
  remind-people-to-vote: ab98343bd2bc18eb
  view-notification-history: 675d77824d320d89
  close-early: e09d92a63b72c516
  reopen: f80ab5f17351d679
  choose-an-audience: a7a00bf75338b395
  check-your-recipients: 7c3de537341ecd1b
  send-the-invitations: 7ca4926c4ff46564
generated:
  introduction: 2813553f859b1160
  invite-people-to-vote-in-a-poll: 2c8ec797cf089853
  invite-guests-or-experts: 2d6adfda45ebd4da
  engage-people-while-a-poll-is-running: 5a7160dd9a19ddc1
  add-voters-to-the-poll: 7e4b0b250e958a6e
  remove-people-from-the-poll: 4f45a23b80cf98b6
  remind-people-to-vote: 6b82900bd72c575b
  view-notification-history: 4db23f56f5beae8f
  close-early: 3f5ff776a28eedad
  reopen: '039906f9baba0d98'
  choose-an-audience: 76a13aafedbea6db
  check-your-recipients: 514e28ab674ebd21
  send-the-invitations: 80beb0def36dfc01
title_source: 10858faa0464257e
title_generated: 0ac6a84d78045aea
---

<!-- translation-section: introduction -->

# Gérer les électeurs

Utilisez **Gérer les électeurs** pour donner à des personnes le droit de voter et les inviter à participer à une proposition ou à un sondage.

<!-- translation-section: invite-people-to-vote-in-a-poll -->

<a id="invite-people-to-vote-in-a-poll"></a>
<a id="add-voters-to-the-poll"></a>

## Inviter des personnes à voter

Après le lancement d’un sondage avec **Personnes sélectionnées uniquement**, la fenêtre **Gérer les électeurs** s’ouvre. Vous pouvez également l’ouvrir en sélectionnant **Gérer les électeurs** sur le sondage.

![Le bouton Gérer les électeurs au bas d’un sondage](proposal_after_start.png)

<!-- translation-section: choose-an-audience -->

### Choisir les destinataires

Cliquez sur le champ vide **Trouver ou inviter des électeurs** pour afficher des suggestions. Elles apparaissent dans cet ordre :

- votre groupe
- les **Délégués de** votre groupe, si votre groupe a des [électeurs délégués](/en/user_manual/groups/delegated_voters)
- les salons de discussion connectés, comme Slack ou Microsoft Teams
- les sous-groupes et le groupe parent
- les membres individuels

Dans un [fil direct](/en/user_manual/discussions/direct_discussions), la liste propose **Participants à la discussion** à la place d’un groupe.

![La fenêtre Gérer les électeurs avec des suggestions pour le groupe, ses délégués, un salon de discussion et un sous-groupe](proposal_invite.png)

<a id="invite-a-subgroup-to-vote"></a>

Sélectionnez un ensemble de destinataires pour inviter ces personnes en une seule fois. Par exemple, sélectionner **Oatmilk Cooperative** inclut les personnes de ce groupe. Vous pouvez également sélectionner un salon de discussion connecté pour y publier l’invitation. Publier une invitation dans un salon de discussion n’ajoute pas ses membres aux électeurs.

<!-- translation-section: check-your-recipients -->

### Vérifier les personnes incluses

Après la sélection d’un ensemble de destinataires, le champ affiche son nom et le nombre de personnes incluses. Vérifiez ce nombre avant d’envoyer l’invitation.

![Oatmilk Cooperative sélectionné, avec le nombre de destinataires affiché sous le champ](proposal_invite_members.png)

Cliquez sur le nom de l’ensemble de destinataires pour afficher les personnes qui le composent. Vous pouvez ensuite sélectionner le **×** à côté d’une personne pour l’exclure de cette invitation. Cela ne la retire pas du groupe.

![Les destinataires du groupe affichés individuellement par leur nom, chacun avec une commande de retrait](proposal_invite_expand.png)

<!-- translation-section: invite-guests-or-experts -->

<a id="invite-guests-or-experts"></a>

### Ajouter des personnes par nom ou par adresse e-mail

Vous pouvez également saisir le nom d’une personne et la sélectionner dans les suggestions, ou saisir une adresse e-mail pour inviter une nouvelle personne. Vous pouvez ajouter plusieurs personnes à la même invitation.

![Une invitation adressée à un membre du groupe et à un invité par e-mail, avec un message prêt à être envoyé](proposal_invite_guest.png)

Les invités ont accès à ce sondage. Si le sondage se trouve dans un fil, ils peuvent également consulter ce fil et ses commentaires. L’invitation ne leur donne pas l’autorisation de publier des commentaires dans le fil, de voter dans ses autres sondages ni de consulter les autres fils du groupe.

<!-- translation-section: send-the-invitations -->

### Envoyer les invitations

Ajoutez un message expliquant ce que vous demandez aux personnes de décider, puis sélectionnez **Inviter**. Laissez **Envoyer des notifications** coché pour avertir les personnes que vous invitez. Décochez cette option pour ajouter des électeurs sans envoyer de notification.

Pour un sondage programmé, sélectionnez **Ajouter des électeurs**. Les personnes reçoivent leur invitation à l’ouverture du vote.

<!-- translation-section: engage-people-while-a-poll-is-running -->

<a id="engage-people-while-a-poll-is-running"></a>

## Après l’invitation

<!-- translation-section: add-voters-to-the-poll -->

### Ajouter d’autres électeurs

Vous pouvez rouvrir **Gérer les électeurs** pour ajouter des personnes à tout moment, y compris avant l’ouverture d’un sondage programmé. La fenêtre affiche également les électeurs déjà présents, en commençant par les personnes ajoutées le plus récemment. Saisissez un nom pour rechercher une personne, ou utilisez les commandes de pagination pour parcourir une liste plus longue.

<!-- translation-section: remove-people-from-the-poll -->

### Retirer des personnes du sondage

Sélectionnez le bouton de corbeille à côté d’une personne et confirmez avec **Supprimer l'électeur** pour lui retirer le droit de voter dans ce sondage. Par exemple, une personne qui organise un vote du conseil peut se retirer si elle n’est pas autorisée à voter.

![La fenêtre Gérer les électeurs affichant les électeurs déjà présents, avec le bouton de corbeille d’un électeur mis en évidence](proposal_invite_remove.png)

Il est impossible de retirer des personnes d’un sondage anonyme. Dans les sondages utilisant des [poids du vote](/en/user_manual/polls/weighted_voting), les administrateurs du fil peuvent également consulter et modifier ces poids ici.

<!-- translation-section: remind-people-to-vote -->

### Rappeler aux personnes de voter

Sélectionnez **Rappel** sur le sondage, choisissez les destinataires du rappel, ajoutez un message, puis sélectionnez **Rappel** pour l’envoyer. Vous pouvez sélectionner **Personnes en attente de vote** pour joindre les personnes dont les réponses sont encore attendues.

![Un rappel adressé aux personnes qui n’ont pas voté, avec un message concernant la date limite de la décision](proposal_remind.png)

<!-- translation-section: view-notification-history -->

### Consulter l’historique des notifications

Ouvrez le menu à trois points (**⋯**) du sondage et sélectionnez **Historique des notifications** pour voir qui a été invité, quand chaque invitation a été envoyée et si elle a été lue, lorsque cette information est disponible.

![L’historique des notifications affichant les destinataires d’une invitation à un sondage](../../discussions/notifying_people/poll_notification_example.png)

<!-- translation-section: close-early -->

### Clôturer un sondage de manière anticipée

Sélectionnez **Clôture anticipée** lorsque tout le monde a voté ou que le sondage n’a plus besoin de rester ouvert.

<!-- translation-section: reopen -->

### Rouvrir un sondage

Sélectionnez **Rouvrir** sur un sondage clôturé, puis définissez une nouvelle date de clôture et une nouvelle heure. Les sondages qui masquent les résultats jusqu’à la clôture du vote, y compris les sondages anonymes, ne peuvent pas être rouverts ; vous pouvez reporter leur heure de clôture tant qu’ils sont encore ouverts.
