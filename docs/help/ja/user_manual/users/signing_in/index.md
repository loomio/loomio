---
title: サインイン
source_revision: ad97f553685def918a7d6e47ac5b66773de2dba8
source_file: docs/help/en/user_manual/users/signing_in/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-11-22'
sections:
  introduction: 15eb32ac962bc715
  sign-in-with-a-passkey: 12038dab660af30d
  sign-in-with-email-and-password: 4918f19e6c5c0e8e
  get-a-sign-in-code: 2857b8b8be3a9bee
  create-an-account: 9ac55c48d388b8a9
  sign-in-with-google: 22b4cd3763d09a34
  other-loomio-sites: 37ad63f50883c4b4
  sign-out: b4ab119ac81aad77
generated:
  introduction: 01047122c4562c0c
  sign-in-with-a-passkey: 878556e973c26711
  sign-in-with-email-and-password: 9ef39d0bd2c1bacc
  get-a-sign-in-code: 14de243efdd07d92
  create-an-account: a5c1491409c9ee87
  sign-in-with-google: 465dfeb2a0f62899
  other-loomio-sites: fe8bfff00ce94744
  sign-out: 5432fe8dae7ec33d
title_source: 824a1d703ce676bb
title_generated: 343ffb055585a6be
---

<!-- translation-section: introduction -->

# サインイン

Loomio.comでは、パスキー、メールアドレスとパスワード、メールで届くサインインコード、またはGoogleでサインインできます。使いやすい方法を選択してください。

![パスキー、メールアドレス、パスワード、メールで届くコードでサインインできるLoomioのフォーム](sign_in_email.png)

<!-- translation-section: sign-in-with-a-passkey -->

## パスキーでサインインする

**パスキーを使用してください**を選択します。最初にメールアドレスを入力する必要はありません。ブラウザーまたは端末に利用可能なLoomioのパスキーが表示され、画面ロック、指紋認証、顔認証、PIN、またはセキュリティキーを使ってパスキーのロックを解除するよう求められます。

プロフィールからパスキーを追加し、名前を付け、削除できます。安全のため、パスキーを変更する前に、Loomioが再度サインインを求める場合があります。それぞれのパスキーには、「仕事用ノートパソコン」や「スマートフォン」など、見分けやすい名前を付けてください。パスキーは作成したLoomioサイトに紐付けられ、端末やパスワードマネージャーを通じて端末間で同期される場合があります。

<!-- translation-section: sign-in-with-email-and-password -->

## メールアドレスとパスワードでサインインする

メールアドレスとパスワードを入力し、**サインイン**を選択します。プライバシーを保護するため、メールアドレスとパスワードのどちらが間違っていても、Loomioは同じエラーメッセージを表示します。

パスキーをまだ追加していない場合、サインインした後に、Loomioがパスキーの追加を案内します。この案内は閉じることができ、Loomioはその選択を記憶します。

パスワードを設定していない場合や、パスワードを思い出せない場合は、代わりに**私にコードを送ってください**を選択します。

<!-- translation-section: get-a-sign-in-code -->

## サインインコードを受け取る

**私にコードを送ってください**を選択し、メールアドレスを入力してフォームを送信します。プライバシーを保護するため、入力したアドレスがアカウントに登録されているかどうかにかかわらず、Loomioは同じ確認メッセージを表示します。

入力したアドレスがアカウントに登録されている場合、Loomioは6桁のコードをメールで送信します。サインインフォームに戻り、コードを入力して**サインイン**を選択します。コードは24時間後に有効期限が切れ、1回だけ使用できます。メールが届かない場合は迷惑メールフォルダーを確認し、アカウントに登録されているアドレスを入力したか確認してください。

![6桁のサインインコードを入力するLoomioのフォーム](sign_in_code.png)

コードでサインインした後に、Loomioがパスワードの設定または変更を案内します。ブラウザーがパスキーに対応している場合は、パスキーの追加も案内します。この案内をスキップして、引き続きメールで届くコードを使用することもできます。

<!-- translation-section: create-an-account -->

## アカウントを作成する

**アカウントを作成する**を選択し、メールアドレスの確認手順に従います。

プライバシーを保護するため、グループへの招待を受け取ったメールアドレスを使用してください。複数のメールアドレスでアカウントを持っている場合は、[アカウントを統合](/en/user_manual/users/merge_accounts)できます。

<!-- translation-section: sign-in-with-google -->

## Googleでサインインする

**Googleでサインイン**を選択し、Googleアカウントでサインインします。そのメールアドレスを使用するLoomioアカウントがすでにある場合、LoomioはGoogleの認証情報をそのアカウントに紐付けます。それ以外の場合は、Loomioが新しいアカウントを作成します。

<!-- translation-section: other-loomio-sites -->

## その他のLoomioサイト

独自のLoomioサイトを運営する組織は、サインイン方法を設定できます。サイトによっては、パスワード、メールで届くコード、パスキー、Google、SAML、その他のOAuthプロバイダーを併用できます。

アカウントの作成に招待が必要なサイトもあります。これらのサイトでは、招待リンクを開いた場合にのみ**アカウントを作成する**が表示されます。

非公開サイトの中には、組織のシングルサインオン（SSO）システムを通じてサインインする必要があるサイトもあります。これらのサイトでは、Loomioのパスワード、メールで届くコード、パスキーは提供されず、別途Loomioアカウントを作成することもできません。組織がパスキーを使用している場合は、組織のサインイン画面でパスキーを使用します。

<!-- translation-section: sign-out -->

## サインアウトする

サイドバーを開き、自分の名前を選択してから、**サインアウト**を選択します。共有のパソコンでは、利用を終えたらブラウザーのタブを閉じるだけでなく、必ずサインアウトしてください。

サインアウトすると、そのブラウザーのセッションは直ちに終了します。Loomioは、セキュリティ調査のために、セッションのIPアドレス、ブラウザー情報、開始時刻と終了時刻を、初期設定では60日間保持します（非公開サイトの運営者は、この期間を変更できます）。アカウントを完全に削除すると、このセッション履歴も削除されます。
