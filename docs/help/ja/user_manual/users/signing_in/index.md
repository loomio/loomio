---
title: サインイン
source_revision: 924e704b41670a012a16528cf88edf90f8d6b572
source_file: docs/en/user_manual/users/signing_in/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-01'
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
  introduction: 786e73209ab68c9e
  sign-in-with-a-passkey: ea16cb975c79ff0e
  sign-in-with-email-and-password: 99f3bbaa00165a6a
  get-a-sign-in-code: e8d370bde240d6ff
  create-an-account: a5c1491409c9ee87
  sign-in-with-google: ba348912f2a2651d
  other-loomio-sites: a82824ee018b16fe
  sign-out: 4fba661cb68f15ca
title_source: 824a1d703ce676bb
title_generated: 343ffb055585a6be
---

<!-- translation-section: introduction -->

# サインイン

Loomio.comでは、パスキー、メールアドレスとパスワード、メールで届くサインインコード、またはGoogleでサインインできます。利用できる方法の中から、使いやすい方法を選べます。

![パスキー、メールアドレス、パスワード、メールで届くコードでサインインできるLoomioのフォーム](sign_in_email.png)

<!-- translation-section: sign-in-with-a-passkey -->

## パスキーでサインインする

**パスキーを使用してください**を選択します。ブラウザーまたは端末に利用可能なLoomioのパスキーが表示され、選択したパスキーのロック解除を求められます。ロック解除には、通常の画面ロック、指紋認証、顔認証、PIN、またはセキュリティキーを使用します。最初にメールアドレスを入力する必要はありません。

プロフィールからパスキーを追加し、名前を付け、削除できます。安全のため、パスキーを変更する前に、Loomioが再度サインインを求める場合があります。それぞれのパスキーには、「仕事用ノートパソコン」や「スマートフォン」など、見分けやすい名前を付けてください。パスキーは作成したLoomioサイトに紐付けられ、端末やパスワードマネージャーによって同期される場合があります。

<!-- translation-section: sign-in-with-email-and-password -->

## メールアドレスとパスワードでサインインする

メールアドレスとパスワードを入力し、**サインイン**を選択します。アカウントのプライバシーを保護するため、メールアドレスまたはパスワードでサインインできない場合、Loomioは同じエラーメッセージを表示します。

パスキーをまだ追加していない場合、パスワードでサインインした後に、Loomioがパスキーの追加を案内します。この案内は閉じることができ、Loomioはその選択を記憶します。

パスワードを設定していない場合や、パスワードを思い出せない場合は、代わりに**私にコードを送ってください**を選択します。

<!-- translation-section: get-a-sign-in-code -->

## サインインコードを受け取る

**私にコードを送ってください**を選択し、メールアドレスを入力してフォームを送信します。入力したアドレスがアカウントに登録されているかどうかにかかわらず、Loomioは同じ確認メッセージを表示します。これにより、他の人がこのフォームを使って、誰がLoomioを利用しているかを調べることを防ぎます。

入力したアドレスがアカウントに登録されている場合、Loomioは6桁のコードを送信します。サインインフォームに戻り、コードを入力して**サインイン**を選択します。サインインコードは通常24時間後に有効期限が切れ、再利用はできません。メールが届かない場合は迷惑メールフォルダーを確認し、アカウントに登録されているアドレスを入力したか確認してください。

![6桁のサインインコードを入力するLoomioのフォーム](sign_in_code.png)

コードでサインインするたびに、Loomioがパスワードの設定または変更を案内します。ブラウザーがパスキーに対応している場合は、別の端末ですでにパスキーを追加していても、新たに追加できます。パスキーを使うと、端末の指紋認証、顔認証、または画面ロックですばやくサインインできます。案内をスキップして、引き続きメールで届くコードを使用することもできます。

<!-- translation-section: create-an-account -->

## アカウントを作成する

**アカウントを作成する**を選択し、メールアドレスの確認手順に従います。

プライバシーを保護するため、グループへの招待を受け取ったメールアドレスを使用してください。複数のメールアドレスでアカウントを持っている場合は、[アカウントを統合](/en/user_manual/users/merge_accounts)できます。

<!-- translation-section: sign-in-with-google -->

## Googleでサインインする

**Googleでサインイン**を選択し、Googleアカウントで認証します。同じメールアドレスのLoomioアカウントがすでにある場合、LoomioはGoogleの認証情報をそのアカウントに紐付けます。

<!-- translation-section: other-loomio-sites -->

## その他のLoomioサイト

独自のLoomioサイトを運営する組織は、サインイン方法を設定できます。サイトによっては、パスワード、メールで届くコード、パスキー、Google、SAML、その他のOAuthプロバイダーを併用できます。

アカウントの作成に招待が必要なサイトもあります。これらのサイトでは、招待リンクを開いた場合にのみ**アカウントを作成する**が表示されます。

SSO専用の非公開サイトには、その組織のサインイン方法だけが表示されます。Loomioが管理するパスワード、メールで届くサインインコード、Loomio上でのアカウント作成、Loomioが管理するパスキーは提供されません。組織がパスキーを使用している場合は、SSOの認証中にIDプロバイダーがパスキーの使用を求めます。

<!-- translation-section: sign-out -->

## サインアウトする

サイドバーを開き、自分の名前を選択してから、**サインアウト**を選択します。共有のパソコンでは、利用を終えたらブラウザーのタブを閉じるだけでなく、サインアウトしてください。
