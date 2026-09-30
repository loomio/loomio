---
title: データのエクスポート
source_revision: 7a01b0fd7d7df0c4bca327a916b01b12e62b967f
source_file: docs/user_manual/groups/data_export/index.md
translated:
  provider: codex/gpt-6-sol
  'on': '2026-09-29'
sections:
  introduction: 5e29f67f9a2084ec
  export-data: 58b5e1d4e6f0b917
  export-group-data-as-csv: 53286ec33e7300d6
  export-group-data-as-html: 101671937dcd6f36
  export-group-data-as-json: 4ec883363fb166ee
  print-thread-to-pdf: 39c48383953f9fd5
  import-your-group-data-on-another-loomio-server: 910ee8af48049e82
generated:
  introduction: 82ea048d34e677a3
  export-data: dc947d3bac9e4108
  export-group-data-as-csv: 83e49ae959cd2a00
  export-group-data-as-html: b8faae2f53e81b67
  export-group-data-as-json: 87366105faeec18d
  print-thread-to-pdf: 8ad9971b7a3560d4
  import-your-group-data-on-another-loomio-server: 7e9a52f7867fc58b
title_source: 29049648f87b87f5
title_generated: e8a1a8a6aba2c93d
---

<!-- translation-section: introduction -->

# グループデータのバックアップまたはエクスポート

グループデータのエクスポート機能では、次のことができます。

- メンバーのデータを含むファイルをダウンロードし、グループのメンバー構成を確認できます。
- スレッドや投票の本文を含むグループのコンテンツをダウンロードし、保存や分析に利用できます。
- 投票結果を表計算ソフトやスクリプト言語で開けます。
- [保存用にスレッドや投票を印刷したり、PDFとして保存したりできます。](#print-thread-to-pdf)
- すべてのユーザー、スレッド、投票、ファイルを含むグループを、別のLoomioサーバーに移せます。

Loomioの管理するサーバーから[自分で運用するサーバー](https://github.com/loomio/loomio)に移る場合にも、この機能を利用できます。

自分でLoomioサーバーを運用していて、管理サービスへの移行を希望する場合、Loomioは米国、EU、オーストラリアでホスティングを提供しています。これらのサーバーにグループを移すには、[お問い合わせください](/contact)。

loomio.comのグローバルホスティングサービスから、欧州向けのloomio.eu、またはオーストラリアとニュージーランド向けのloomio.nzにグループを移す場合は、[お問い合わせください](/contact)。

<!-- translation-section: export-data -->

## データのエクスポート

3点メニューをクリックしてグループのドロップダウンメニューを開き、**グループデータのエクスポート**を選択します。

![Oatmilk Cooperativeのメニューにあるグループデータのエクスポート](group_export_group_data.png)

<!-- translation-section: export-group-data-as-csv -->

### グループデータをCSV形式でエクスポート

*MS ExcelやGoogle スプレッドシートなどの表計算ソフトでグループデータを扱う場合に使用します。*

LoomioがバックグラウンドでCSVファイルを作成し、準備ができたらダウンロードリンクをメールで送ります。リンクの有効期間は1週間です。

<!-- translation-section: export-group-data-as-html -->

### グループデータをHTML形式でエクスポート

*データを保存用の記録として残す場合に使用します。*

LoomioがバックグラウンドでHTMLファイルを作成し、準備ができたらダウンロードリンクをメールで送ります。リンクの有効期間は1週間です。

<!-- translation-section: export-group-data-as-json -->

### グループデータをJSON形式でエクスポート

*グループデータを自分で運用するLoomioサーバーに移す場合に使用します。*

エクスポートするには、グループの管理者である必要があります。JSON形式のエクスポートには、次のデータが含まれます。

- グループ、メンバー、参加申請
- 対象グループのスレッド、コメント、リアクション、タグ、テンプレート、通知、関連する記録
- 投票、選択肢、票、結論。ただし、匿名投票は終了後にのみ含まれます
- 所属しているサブグループ
- 親グループの管理者として親グループをエクスポートする場合は、所属していないサブグループも含め、公開中と終了済みのサブグループ
- 対象コンテンツに添付されたファイルや画像への参照

JSON形式のエクスポートには、次のデータは含まれません。

- 所属していない非公開のサブグループと、そのメンバー構成やコンテンツ
- 削除待ちのサブグループ
- 終了していない匿名投票
- グループに属さないダイレクトスレッドと投票

まもなく、JSONファイルのダウンロードリンクを記載したメールが届きます。

<!-- translation-section: print-thread-to-pdf -->

## スレッドをPDFとして印刷

スレッドのコピーを取り出し、別のファイル保管場所に保存できます。

**印刷する**では、スレッドの書式とともに、すべてのコメント、投票、票、結論が保持されます。

スレッドの3点メニュー（⋯）をクリックし、**印刷する**を選択します。LoomioがHTMLページを生成します。ブラウザーの印刷機能を使って、そのページを印刷するか、「PDFとして保存」できます。

ページをコピーして、文書エディター、ファイル、データ保管場所に貼り付けることもできます。

![返却可能なボトルに関するディスカッションの印刷操作](discussion_print_discussion.png#width-90)

<!-- translation-section: import-your-group-data-on-another-loomio-server -->

## 別のLoomioサーバーにグループデータをインポート

自分でLoomioサーバーを設定する方法は、こちらをご覧ください: https://github.com/loomio/loomio

自分でLoomioを運用していて、エクスポートしたデータをインポートする場合は、次の手順に従います。

.jsonファイルをコンテナーインスタンスの`import`フォルダーにコピーします。

`scp your-group-data.json username@some-domain.org:loomio-deploy/import`

実行中のRailsコンソールにアクセスします。

`docker exec -ti loomio-app rails console`

サービスを呼び出します。

`GroupExportService.import('/import/your-group-data.json')`
