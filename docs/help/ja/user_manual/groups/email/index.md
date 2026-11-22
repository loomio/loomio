---
title: メールアドレス
source_revision: ad97f553685def918a7d6e47ac5b66773de2dba8
source_file: docs/help/en/user_manual/groups/email/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-11-22'
sections:
  introduction: '03039e0babf5a9b6'
  preventing-unauthorized-emails: f4b8d2eaf0d79f01
generated:
  introduction: '041496a764a9ff37'
  preventing-unauthorized-emails: c2bfda802efb2bd9
title_source: f2488fd4ef4adbc6
title_generated: dd4433300c45394f
---

<!-- translation-section: introduction -->

# メールを送信してグループにスレッドを作成する

Loomioの各グループには専用のメールアドレスがあります。このアドレスにメールを送信または転送すると、グループに新しいスレッドを作成できます。

グループのメールアドレスは、グループページで確認できます。

![グループページのメールアドレスの表示位置](email_email_button.png)

このアドレスにメールを送信すると、Loomioが新しいスレッドを作成します。メールの件名がスレッドのタイトルになり、本文がスレッドの説明になります。添付ファイルもスレッドに追加されます。

Loomioはメールの差出人（From）アドレスをもとに送信者をグループのメンバーと照合し、そのメンバーをスレッドの作成者に設定します。

<!-- translation-section: preventing-unauthorized-emails -->

## 許可されていないメールを防ぐ

メンバー以外によるスレッドの作成を防ぐため、Loomioでは受信メールの差出人（From）アドレスがグループのメンバーのメールアドレスと一致することを必須としています。

メンバーが認識されていないアドレスからメールを送信すると、Loomioはメールを保留し、グループ管理者に通知します。グループ管理者はメールを承認してそのアドレスを該当メンバーのエイリアスとして追加するか、そのアドレスからの今後のメールを拒否できます。

エイリアスを追加すると、以降はそのアドレスからのメールですぐにスレッドが作成されます。

![認識されていないメールの承認ボタンと拒否ボタン](email_unreleased_emails.png)
