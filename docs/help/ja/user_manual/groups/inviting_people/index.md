---
title: メンバーを招待する
source_revision: ad97f553685def918a7d6e47ac5b66773de2dba8
source_file: docs/help/en/user_manual/groups/inviting_people/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-11-22'
sections:
  introduction: 74059ea9fbb835df
  send-invitations-via-email: 31fb589497c62dd5
  invite-many-at-once: b16b041c438139ef
  invite-people-to-subgroups: ebabc8be61151327
  share-a-link-to-your-group: 1d9e5c284cc370df
  request-to-join-group: bf2adeaf16292fe4
  review-membership-requests: 7006378e870d8c63
  managing-invitations: 4213f2a1400cf35d
  re-send-invitations: 170acb378f6443dd
  cancelling-invitations: f45e19cbeaf8b752
  invitation-notification-history: edfe660cfce18887
generated:
  introduction: b55ab2aa78f05f0a
  send-invitations-via-email: bc689b4a3d69d435
  invite-many-at-once: 680aca86e95da6c6
  invite-people-to-subgroups: 0b0bc3c6e63c22d0
  share-a-link-to-your-group: ed83815d7f94a3bd
  request-to-join-group: 225594c988ec4b6d
  review-membership-requests: e06da4fef711a04a
  managing-invitations: 2a25775256980537
  re-send-invitations: ce3a92466f5c5e12
  cancelling-invitations: de6c8fe7574c55ff
  invitation-notification-history: fb17c24f5d03dbe8
title_source: b926eb8921d85971
title_generated: 8443acb671cc4a96
---

<!-- translation-section: introduction -->

# Loomioのグループにメンバーを招待する

メールでLoomioのグループにメンバーを招待したり、招待リンクを共有したり、参加申請を受け付けたりできます。まず、グループページの**メンバー**タブを開きます。

![](group_join_group_invite.png)

<!-- translation-section: send-invitations-via-email -->

## メールで招待を送信する

**メンバー**タブで**招待する**を選択すると、1回限り使用できる招待リンクを含むメールを送信できます。受信者は既存のLoomioアカウントで参加するか、新しいアカウントを作成できます。

![](group_invite_email.png)

<!-- translation-section: invite-many-at-once -->

### 一度に多くの人を招待する

メールアドレスをカンマまたはスペースで区切って入力するか貼り付けると、一度に最大100人を招待できます。

組織内のグループに人を招待する際は、所属している親グループや関連するサブグループも選択できます。選択したグループを個々の人に展開すると、招待しない人を削除できます。すでにメンバーになっている人は自動的に除外されます。

>[!Tip]
>Google スプレッドシートやMicrosoft Excelの列からメールアドレスをコピーして、招待欄に直接貼り付けることができます。

**招待する**を選択すると、Loomioは各メールアドレスに、1回限り使用できる固有の招待リンクを現在設定されている言語で送信します。

<!-- translation-section: invite-people-to-subgroups -->

### サブグループにメンバーを招待する

親グループに人を招待する際に、1つ以上のサブグループにも同時に追加できます。招待を承諾したときに参加してもらうサブグループのチェックボックスを選択します。

![](group_invite_email_subgroups.png)

<!-- translation-section: share-a-link-to-your-group -->

## グループへのリンクを共有する

**共有**を選択すると、ニュースレター、チャットチャンネル、メール、ウェブサイトで使用できる、再利用可能な招待リンクを生成できます。

![](group_invite_sharable_link.png)

既存のリンクからの参加を停止するには、**このリンクをリセット**を選択します。古いリンクが無効になり、新しいリンクが作成されます。

<!-- translation-section: request-to-join-group -->

## グループへの参加を申請する

`https://www.loomio.com/group-name`などのグループURLから、公開グループや非公開グループへの参加を申請できます。訪問者は公開されているグループ情報を確認し、**グループに参加する**を選択して参加時の質問に回答し、参加申請を送信します。

![](group_join_group.png)

参加時の質問では、申請者が自己紹介や参加を希望する理由を記入できます。

![](group_request_to_join.png)

参加申請の審査を必須にするには、[グループのプライバシー](/en/user_manual/groups/settings/privacy#how-people-join)で**参加を申請します**を選択します。グループ設定では、参加時の質問も変更できます。

<!-- translation-section: review-membership-requests -->

### 参加申請を審査する

グループ管理者と、メンバーを追加する権限を持つメンバーは、**メンバー**タブの**参加申請**で申請を審査できます。

![](group_review_request_to_join.png)

各申請に対して、次の操作ができます。

- **承認**を選択すると、申請者をメンバーとして追加し、通知します。
- **拒否**を選択すると、申請者に通知せずに処理を終了し、再申請を許可しません。
- **衰退**を選択すると、メールと通知で理由を送信します。申請者は後から再申請できます。

![](group_decline_request_to_join.png)

<!-- translation-section: managing-invitations -->

## 招待を管理する

**メンバー**タブでフィルターメニューを開き、**招待状**を選択すると、承諾待ちの招待を確認できます。招待の横にある操作メニューから、その招待を管理できます。

![](group_invite_members_filter.png)

招待が承諾される前に、招待した人をグループ管理者にしたり、肩書き（「ITサポート」など）を設定したりすることもできます。

<!-- translation-section: invitation-notification-history -->

### 招待の配信履歴

招待メールが届かない場合、グループ管理者は配信状況を確認できます。**メンバー**タブで対象者の名前の横にある操作メニューを開き、**招待の配信履歴**を選択すると、招待が送信された日時と、記録された配信上の問題を確認できます。

<!-- translation-section: re-send-invitations -->

### 招待を再送信する

招待メールを紛失したり見落としたりした場合は、**メンバー**タブで対象者の名前の横にある操作メニューを開き、**招待状を再送信する**を選択します。

![](group_invite_resend_invitation.png)

<!-- translation-section: cancelling-invitations -->

### 招待を取り消す

メールアドレスを間違えた場合や、招待する予定を変更した場合は、**メンバー**タブで対象の招待の横にある操作メニューを開き、**招待をキャンセルする**を選択します。

![](group_invite_cancel_invitation.png)
