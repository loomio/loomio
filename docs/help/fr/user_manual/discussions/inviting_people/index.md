---
sections:
  introduction: d7b020cbed90ea35
  open-invite-people: 708d0f7d7fcd3b93
  choose-an-audience: 39117e2ca66c0b15
  check-your-recipients: abfd43038a55b47c
  invite-by-name-or-email: 2d5b006d863d7491
  guest-access: 55ce2b30a1bf0ba7
  send-invitations-and-notifications: 9a2b42b6479c7241
  manage-thread-members: 180842248a05ca0a
generated:
  introduction: 554aaa31dda5156e
  open-invite-people: 18b759a8453379a1
  choose-an-audience: fb3a2ada68ef7a0d
  check-your-recipients: aa7af825bc638f40
  invite-by-name-or-email: 42fbbf1ffb5e7ad8
  guest-access: c36202adb0ec56da
  send-invitations-and-notifications: 6402c03811f46054
  manage-thread-members: 83c83d136750e0e3
title: Inviter des personnes
title_source: b926eb8921d85971
title_generated: 6dcdecac01939914
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-11-22'
source_revision: ad97f553685def918a7d6e47ac5b66773de2dba8
source_file: docs/help/en/user_manual/discussions/inviting_people/index.md
---

<!-- translation-section: introduction -->

# Inviter des personnes à une discussion

Invitez des personnes pour attirer leur attention sur une discussion ou donner à des invités accès à un fil particulier. Vous pouvez inviter votre groupe, un sous-groupe, le groupe parent ou des personnes individuellement, et publier des invitations dans des salons de discussion connectés.

<!-- translation-section: open-invite-people -->

## Ouvrir Inviter des personnes

Sélectionnez **Inviter des personnes** dans la barre latérale droite du fil pour ouvrir **Gérer les membres du fil de discussion**.

![Inviter des personnes dans la barre latérale du fil](thread_invite_icon.png)

<!-- translation-section: choose-an-audience -->

## Choisir les destinataires

Sélectionnez le champ vide **Trouver ou inviter des personnes** pour voir les groupes et canaux disponibles :

- le groupe auquel appartient la discussion
- les **Délégués de** ce groupe, s’il possède des [électeurs délégués](/en/user_manual/groups/delegated_voters)
- les salons de discussion connectés, comme Slack ou Microsoft Teams
- les sous-groupes et le groupe parent

![Gérer les membres du fil de discussion avec des suggestions pour le groupe, ses délégués, un salon de discussion connecté et un sous-groupe](thread_invite.png)

### Inviter votre groupe

Sélectionnez le nom de votre groupe pour informer ses membres de la discussion. Ils y ont déjà accès grâce à leur appartenance au groupe.

### Inviter un sous-groupe ou le groupe parent

Sélectionner un autre groupe invite ses membres à cette discussion. Toute personne qui n’appartient pas au groupe de la discussion est ajoutée en tant qu’invité : elle peut lire ce fil et y participer sans rejoindre le groupe ni accéder à ses autres discussions privées.

Par exemple, le sous-groupe **Bottle Trial Board** peut inviter son groupe parent, **Oatmilk Cooperative**, à discuter de l’essai des bouteilles. Les membres de la coopérative qui ne font pas partie du conseil sont ajoutés en tant qu’invités pour ce fil uniquement.

![Le groupe parent Oatmilk Cooperative sélectionné pour une invitation à une discussion de Bottle Trial Board, avec le nombre de destinataires et un message demandant à chacun d’examiner le plan](thread_invite_parent_group.png)

### Inviter des délégués

Sélectionnez **Délégués de** pour un groupe afin d’inviter uniquement ses électeurs délégués. Cela peut être utile pour demander aux personnes responsables d’une décision d’en discuter d’abord.

### Publier dans un salon de discussion

Sélectionnez un salon de discussion connecté pour y publier l’invitation par l’intermédiaire de son chatbot. Publier dans un salon de discussion ne donne pas à ses membres accès à une discussion privée ; invitez ces personnes en tant qu’invités si elles ont besoin d’y accéder. Consultez [Intégrations de messagerie](/en/user_manual/integrations/chatbots).

<!-- translation-section: check-your-recipients -->

## Vérifier les destinataires inclus

Après avoir choisi un groupe ou un canal, vérifiez le nombre de destinataires sous le champ. Sélectionnez le nom du groupe pour afficher les personnes qui le composent, puis sélectionnez **×** à côté de chaque personne que vous souhaitez exclure. Cela ne les retire pas de leur groupe et ne supprime pas les accès dont elles disposent déjà.

![Les destinataires du groupe parent affichés individuellement, Samira Patel et Alex Morgan, avec une commande de retrait à côté de chaque nom](thread_invite_expand.png)

<!-- translation-section: invite-by-name-or-email -->

## Inviter des personnes par nom ou par adresse e-mail

Saisissez le nom d’une personne et sélectionnez-la dans la liste, ou saisissez une adresse e-mail pour inviter une nouvelle personne. Vous pouvez inclure plusieurs personnes dans la même invitation.

![Un invité sélectionné par adresse e-mail dans Gérer les membres du fil de discussion](invite_guest.png)

<!-- translation-section: guest-access -->

## Ce que les invités peuvent faire

Les invités peuvent lire le fil, y compris ses commentaires antérieurs, et ajouter des commentaires et des réponses. Inviter une personne à un fil ne fait pas d’elle un membre du groupe et ne lui donne pas accès aux autres discussions privées du groupe.

Les invités peuvent voter dans les sondages dont le réglage est **Toute personne dans le fil**. Pour les sondages dont le réglage est **Personnes sélectionnées uniquement**, ajoutez-les séparément via [Gérer les électeurs](/en/user_manual/polls/manage_voters).

Les administrateurs du groupe peuvent inviter des invités lorsque l’abonnement du groupe permet l’accès des invités. Les membres du groupe peuvent également inviter des invités si le groupe l’autorise. Consultez [Permissions du groupe](/en/user_manual/groups/settings/permissions).

<!-- translation-section: send-invitations-and-notifications -->

## Envoyer des invitations et des notifications

Ajoutez, si vous le souhaitez, un message expliquant pourquoi vous invitez ces personnes, puis sélectionnez **Inviter ou notifier**. Les nouvelles personnes reçoivent une invitation ; les personnes qui y ont déjà accès reçoivent une notification avec votre message.

Les destinataires reçoivent une notification dans Loomio. L’envoi par e-mail ou par notification push dépend de leurs [paramètres de notification](/en/user_manual/users/email_settings). Inviter des personnes ne les abonne pas aux e-mails pour chaque commentaire ultérieur ; elles peuvent choisir leur propre paramètre de notification pour le fil.

Ouvrez **Notifié⋅e(s)** dans la barre latérale du fil pour voir qui a reçu une notification et si celle-ci a été lue ou ouverte, lorsque ces informations sont disponibles. **Vu par** indique qui a ouvert le fil. Consultez [Notifications et membres](/en/user_manual/discussions/using_discussions#notifications-and-members).

<!-- translation-section: manage-thread-members -->

## Trouver ou retirer un membre du fil

Utilisez **Trouver ou inviter des personnes** pour filtrer la liste des membres actuels du fil. Videz le champ pour afficher à nouveau la liste complète et utilisez les commandes de pagination pour parcourir les listes plus longues. La sélection de destinataires remplace temporairement la liste des membres par le message d’invitation jusqu’à l’envoi de l’invitation ou à l’effacement de la sélection.

Les administrateurs du fil et les administrateurs du groupe peuvent retirer un invité en ouvrant le menu à trois points (**⋯**) à côté de son nom et en sélectionnant **Retirer de la discussion**. Les membres du groupe conservent leur accès grâce à leur appartenance au groupe.
