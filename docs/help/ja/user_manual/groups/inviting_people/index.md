---
title: メンバーを招待する
source_revision: 924e704b41670a012a16528cf88edf90f8d6b572
source_file: docs/en/user_manual/groups/inviting_people/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-01'
sections:
  introduction: 55a6bcc670aa6224
  send-invitations-via-email: bbc814cba35c9541
  invite-many-at-once: 971aad55946f5f1d
  invite-people-to-subgroups: 69a78a72938caca5
  share-a-link-to-your-group: cfa22d9b153f17af
  request-to-join-group: 37a250936884173f
  review-membership-requests: 678163f67ce197d5
  managing-invitations: 25d2b33504493b14
  re-send-invitations: 76c7fc660f7e3d42
  cancelling-invitations: f3df8386eeda62f5
generated:
  introduction: d0472b30afa3ea26
  send-invitations-via-email: 060c3642105461e9
  invite-many-at-once: 9a64ce568e061b6e
  invite-people-to-subgroups: '00819b2abb4a85c9'
  share-a-link-to-your-group: 98d05ab6d5aeb70c
  request-to-join-group: c23a8320f2a03e04
  review-membership-requests: 134f5c9fcb78b67f
  managing-invitations: 6fdff47a1de2fe7e
  re-send-invitations: 72c721832ea9504b
  cancelling-invitations: b73b9af2ad261323
title_source: b926eb8921d85971
title_generated: 8443acb671cc4a96
---

<!-- translation-section: introduction -->

# メンバーを招待する

グループページで**メンバー**タブをクリックすると、メンバーを管理できます。

メールアドレスを指定して特定の人をグループに**招待する**ことも、メール、ニュースレター、チャット、ウェブサイトでグループへのリンクを**共有**することもできます。

![](group_join_group_invite.png)

<!-- translation-section: send-invitations-via-email -->

## メールで招待を送信する

**メンバー**タブで**招待する**をクリックすると、1回限り使用できる招待リンクを含むメールを送信できます。受信者はLoomioのユーザーアカウントを作成して、グループに参加できます。

受信者がすでにLoomioのユーザーアカウントを持っている場合は、既存のアカウントで招待を承諾してグループに参加できます。

![](group_invite_email.png)

<!-- translation-section: invite-many-at-once -->

### 一度に多くの人を招待する

「誰を招待しますか」欄に複数のメールアドレスを入力するか、コピーして貼り付けると、一度に最大100人にメールで招待を送信できます。メールアドレスはカンマまたはスペースで区切ります。

組織内のグループに人を招待する際は、所属している親グループと関連するサブグループが招待先の候補として表示されます。グループを選択し、そのグループのチップを選択すると、招待先が個々の人に展開されます。招待を送信する前に、招待しない人を削除できます。招待先のグループにすでに所属している人は除外されます。

>[!Tip]
>Google スプレッドシートやExcelの列からメールアドレスをコピーして、招待欄に貼り付けます。

**招待する**をクリックすると、入力した各メールアドレスに、1回限り使用できる固有の招待リンクを含むメールが送信されます。このメールは、現在設定されている言語で送信されます。

<!-- translation-section: invite-people-to-subgroups -->

### サブグループにメンバーを招待する

上記と同じ手順で、**メンバーを招待する**ボタンを使うと、親グループと1つ以上のサブグループに同時に招待できます。グループへの参加と同時に所属してもらうサブグループの横にあるチェックボックスを選択します。

![](group_invite_email_subgroups.png)

<!-- translation-section: share-a-link-to-your-group -->

## グループへのリンクを共有する

**共有**ボタンでグループへのリンクを共有できます。メール、ニュースレター、チャットでリンクを送信したり、ウェブサイトに掲載したりする場合に利用できます。

![](group_invite_sharable_link.png)

「コピー」アイコンをクリックしてリンクをクリップボードにコピーし、メール、ニュースレター、チャットチャンネルに貼り付けます。

このリンクからの参加を停止するには、「このリンクをリセット」をクリックします。既存のリンクは使用できなくなり、新しいリンクが作成されます。

<!-- translation-section: request-to-join-group -->

## グループへの参加を申請する

公開グループや非公開グループへの参加を申請できます。`https://www.loomio.com/group-name`などのグループURLを共有します。グループページを開くと、公開されているグループ情報を確認し、**グループに参加する**を選択して参加時の質問に回答し、参加申請を送信できます。

![](group_join_group.png)

参加時の質問では、自己紹介や参加を希望する理由を記入できます。

![](group_request_to_join.png)

参加申請の審査を必須にするには、[グループのプライバシー](/en/user_manual/groups/settings/privacy#how-people-join)で**承認を申請する**を選択します。グループ設定では、参加時の質問も変更できます。

<!-- translation-section: review-membership-requests -->

### 参加申請を審査する

グループ管理者と、メンバーを追加する権限を持つメンバーは、**メンバー**タブの**参加申請**セクションで申請を審査します。審査では、次の操作ができます。

![](group_review_request_to_join.png)

- 申請を**承認**して、申請者をメンバーとして追加し、通知します。
- 申請を**拒否**して、申請者に通知せずに処理を終了し、再申請を許可しません。
- 決定の理由を説明するメッセージを添えて、申請に対して**衰退**を選択します。Loomioは申請者にメールと通知でメッセージを送信し、申請者は再申請できます。

衰退ボタンを選択すると、メッセージを記入するか、申請を拒否できます。

![](group_decline_request_to_join.png)

<!-- translation-section: managing-invitations -->

## 招待を管理する

招待を管理するには、グループページのメンバータブでフィルターのドロップダウンメニューを開き、**招待状**を選択します。メンバーの右側にある3点メニュー（**⋮**）をクリックすると、個々の招待を管理できます。

![](group_invite_members_filter.png)

招待が承諾される前に、その人を管理者にしたり、グループ内での肩書き（「ITサポート」など）を設定したりすることもできます。

<!-- translation-section: re-send-invitations -->

### 招待を再送信する

まだグループに参加していない人に、参加を促すことができます。招待メールを紛失したり、招待を忘れていたりする場合は、メンバーページの名前の横にあるドロップダウンメニューから再送信できます。

招待を再送信する人の横にある3点メニュー（**⋮**）をクリックし、**招待状を再送信する**を選択します。

![](group_invite_resend_invitation.png)

<!-- translation-section: cancelling-invitations -->

### 招待を取り消す
メールアドレスを間違えた場合や、招待する予定を変更した場合は、グループページのメンバータブから招待を取り消せます。メンバーへの招待の右側にあるドロップダウンメニュー（**⋮**）で**招待を取り消す**を選択します。

![](group_invite_cancel_invitation.png)
