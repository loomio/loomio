---
title: サインイン
source_revision: 7a01b0fd7d7df0c4bca327a916b01b12e62b967f
source_file: docs/user_manual/users/signing_in/index.md
translated:
  provider: codex/gpt-6-sol
  'on': '2026-09-30'
sections:
  introduction: 9aa03b133cc213ce
  sign-in-with-a-passkey: c685bd268243f8f5
  sign-in-with-email-and-password: 20db7df775a273d8
  get-a-sign-in-code: 50bf073c798941bc
  create-an-account: 9ac55c48d388b8a9
  sign-in-with-google: 1e8bfdcee244d0bd
  other-loomio-sites: 123e31828ab49002
  sign-out: 96c8936d1a7aef07
generated:
  introduction: a4bbe1a96fa68135
  sign-in-with-a-passkey: 070a16b3cb66493e
  sign-in-with-email-and-password: 238bdd8d33fe8309
  get-a-sign-in-code: 0b9d75d2ab058b08
  create-an-account: f35ed491e267231d
  sign-in-with-google: 4f0c086aef72743c
  other-loomio-sites: f3545aca092091e3
  sign-out: 2cf4834131eadfe7
title_source: 824a1d703ce676bb
title_generated: 343ffb055585a6be
---

<!-- translation-section: introduction -->

# サインイン

Loomio.comでは、パスキー、メールアドレスとパスワード、メールで届くサインインコード、またはGoogleでサインインできます。利用できる方法から選べます。

![パスキー、メールアドレス、パスワード、メールで届くコードの選択肢があるLoomioのサインインフォーム](sign_in_email.png)

<!-- translation-section: sign-in-with-a-passkey -->

## パスキーでサインインする

**パスキーを使用してください**を選択します。ブラウザまたはデバイスに、利用できるLoomioのパスキーが表示されます。パスキーを選び、通常の画面ロック、指紋、顔認証、PIN、またはセキュリティキーでロックを解除します。先にメールアドレスを入力する必要はありません。

プロフィールからパスキーの追加、名前の設定、削除ができます。セキュリティのため、変更前に再度サインインを求められる場合があります。各パスキーには「仕事用ノートパソコン」や「スマートフォン」など、識別しやすい名前を付けてください。パスキーは作成したLoomioサイトに紐付き、デバイスやパスワードマネージャーによって同期される場合があります。

<!-- translation-section: sign-in-with-email-and-password -->

## メールアドレスとパスワードでサインインする

メールアドレスとパスワードを入力し、**サインイン**を選択します。アカウントのプライバシーを守るため、メールアドレスとパスワードのどちらが原因でサインインできない場合も、Loomioは同じエラーを表示します。

パスキーをまだ追加していない場合、パスワードでサインインした後に追加を案内します。案内は閉じることができ、Loomioはその選択を記憶します。

パスワードを設定していない場合や思い出せない場合は、代わりに**私にコードを送ってください**を選択します。

<!-- translation-section: get-a-sign-in-code -->

## サインインコードを受け取る

**私にコードを送ってください**を選択し、メールアドレスを入力してフォームを送信します。そのアドレスにアカウントがあるかどうかに関係なく、Loomioは同じ確認メッセージを表示します。これにより、ほかの人がフォームを使ってLoomioの利用者を調べることはできません。

入力したアドレスがアカウントに登録されている場合、Loomioは6桁のコードを送信します。サインインフォームに戻ってコードを入力し、**サインイン**を選択します。サインインコードの有効期限は通常24時間で、再利用できません。メールが届かない場合は迷惑メールフォルダーを確認し、アカウントに登録したアドレスを入力したか確かめてください。

![6桁のサインインコードを入力するLoomioのフォーム](sign_in_code.png)

コードでサインインするたびに、Loomioはパスワードの設定または変更を案内します。ブラウザがパスキーに対応していれば、別のデバイスでパスキーを追加済みでも、新たに追加できます。パスキーを使うと、デバイスの指紋、顔認証、または画面ロックですばやくサインインできます。案内をスキップし、引き続きメールで届くコードを使うこともできます。

<!-- translation-section: create-an-account -->

## アカウントを作成する

**アカウントを作成する**を選択し、メールアドレスの確認手順に従います。

プライバシーを守るため、グループへの招待を受け取ったメールアドレスを使用してください。複数のメールアドレスでアカウントを持っている場合は、[アカウントを統合](/en/user_manual/users/merge_accounts)できます。

<!-- translation-section: sign-in-with-google -->

## Googleでサインインする

**Googleでサインイン**を選択し、Googleアカウントで認証します。同じメールアドレスのLoomioアカウントがすでにある場合、LoomioはGoogleアカウントをそのアカウントに連携します。

<!-- translation-section: other-loomio-sites -->

## その他のLoomioサイト

独自のLoomioサイトを運営する組織は、サインイン方法を設定できます。サイトによっては、パスワード、メールで届くコード、パスキー、Google、SAML、その他のOAuthプロバイダーを併用できます。

アカウントの作成に招待が必要なサイトもあります。そのようなサイトでは、招待リンクからアクセスした場合にのみ**アカウントを作成する**が表示されます。

SSO専用の非公開サイトには、組織のサインイン方法のみが表示されます。Loomioが管理するパスワード、メールで届くサインインコード、サイト上でのアカウント作成、Loomioが管理するパスキーは利用できません。組織がパスキーを使用している場合は、SSO中に組織の認証サービスからパスキーの使用を求められます。

<!-- translation-section: sign-out -->

## サインアウトする

サイドバーを開き、自分の名前を選択してから**サインアウト**を選択します。共有のパソコンでは、ブラウザのタブを閉じるだけでなく、使い終わったらサインアウトしてください。
