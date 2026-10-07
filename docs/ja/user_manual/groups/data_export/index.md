---
title: データのエクスポート
source_revision: cd2e1e63e611688362e80009f50b8ed25025ba8b
source_file: docs/en/user_manual/groups/data_export/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-07'
sections:
  introduction: 5e29f67f9a2084ec
  export-data: 58b5e1d4e6f0b917
  export-group-data-as-csv: 53286ec33e7300d6
  export-group-data-as-html: 101671937dcd6f36
  export-group-data-as-json: aa310889d0854550
  print-thread-to-pdf: 39c48383953f9fd5
  import-your-group-data-on-another-loomio-server: 910ee8af48049e82
generated:
  introduction: '08204f8655220845'
  export-data: ca71d878f579c764
  export-group-data-as-csv: 0ad311ba86a4e492
  export-group-data-as-html: 846f521da886f3dd
  export-group-data-as-json: cb7d5f9d59155c2e
  print-thread-to-pdf: c338f22ca5e6d9a2
  import-your-group-data-on-another-loomio-server: e38bb967c4b4743e
title_source: 29049648f87b87f5
title_generated: e8a1a8a6aba2c93d
---

<!-- translation-section: introduction -->

# グループデータのバックアップまたはエクスポート

グループデータのエクスポート機能では、次のことができます。

- メンバーのデータを含むファイルをダウンロードして、グループのメンバー構成を確認できます。
- スレッドやアンケートの本文を含むグループのコンテンツをダウンロードして、保管や分析に利用できます。
- アンケートの結果を表計算ソフトやスクリプト言語で開けます。
- [保管用にスレッドやアンケートを印刷したり、PDFとして保存したりできます。](#print-thread-to-pdf)
- すべてのユーザー、スレッド、アンケート、ファイルを含むグループを、別のLoomioサーバーに移行できます。

Loomioが管理するサーバーから[独自のサーバーへ](https://github.com/loomio/loomio)移行する場合に、この機能を利用できます。

独自のLoomioサーバーの運用を終了したい場合、Loomioは米国、EU、オーストラリアでマネージドホスティングを提供しています。これらのサーバーへのグループの移行を希望する場合は、[お問い合わせください](/contact)。

loomio.comのグローバルホスティングサービスから、ヨーロッパ向けのloomio.eu、またはオーストラリアとニュージーランド向けのloomio.nzへLoomioのグループを移行する場合は、[お問い合わせください](/contact)。

<!-- translation-section: export-data -->

## データのエクスポート

3つの点をクリックしてグループのドロップダウンメニューを開き、**グループデータのエクスポート**を選択します。

![Oatmilk Cooperativeのメニューにあるグループデータのエクスポート操作](group_export_group_data.png)

<!-- translation-section: export-group-data-as-csv -->

### グループデータをCSVとしてエクスポート

*MS ExcelやGoogle Sheetsなどの表計算ソフトでグループデータを扱う場合に使用します。*

LoomioはバックグラウンドでCSVファイルを準備し、準備ができるとダウンロードリンクをメールで送信します。リンクは1週間利用できます。

<!-- translation-section: export-group-data-as-html -->

### グループデータをHTMLとしてエクスポート

*データを保管用に保存する場合に使用します。*

LoomioはバックグラウンドでHTMLファイルを準備し、準備ができるとダウンロードリンクをメールで送信します。リンクは1週間利用できます。

<!-- translation-section: export-group-data-as-json -->

### グループデータをJSONとしてエクスポート

*グループデータをセルフホストのLoomioインスタンスへ移行する場合に使用します。*

エクスポートするには、グループの管理者である必要があります。JSONエクスポートには次のものが含まれます。

- グループ、そのメンバー、参加申請
- 対象のグループのスレッド、コメント、リアクション、タグ、テンプレート、通知、および関連レコード
- アンケート、選択肢、投票、結論（匿名アンケートは締め切り後にのみ含まれます）
- 所属しているサブグループ
- 親グループの管理者として親グループをエクスポートする場合、所属していないものも含め、公開、非公開、および親グループに表示されるサブグループ
- 対象のコンテンツに添付されたファイルや画像への参照

JSONエクスポートには次のものは含まれません。

- 所属していない秘密のサブグループ、およびそのメンバー情報とコンテンツ
- 削除待ちのサブグループ
- まだ締め切られていない匿名アンケート
- グループに属していないダイレクトスレッドやアンケート

しばらくすると、JSONファイルのダウンロードリンクを記載したメールが届きます。

<!-- translation-section: print-thread-to-pdf -->

## スレッドをPDFとして印刷

スレッドのコピーを取り出して、別のファイル保管場所に保存する必要がある場合があります。

スレッドの**印刷する**機能では、スレッドの書式とともに、すべてのコメント、アンケート、投票、結論が保持されます。

スレッドの3つの点のメニュー（⋯）をクリックし、**印刷する**を選択します。LoomioがHTMLページを生成するので、ブラウザーの印刷機能を使って印刷したり、「PDFとして保存」したりできます。

ページをコピーして、文書エディター、ファイル、データリポジトリに貼り付けることもできます。

![リターナブル瓶についてのディスカッションの印刷操作](discussion_print_discussion.png#width-90)

<!-- translation-section: import-your-group-data-on-another-loomio-server -->

## 別のLoomioサーバーにグループデータをインポート

独自のLoomioサーバーのセットアップ手順は、次のページをご覧ください： https://github.com/loomio/loomio

独自のLoomio環境をホストしていて、エクスポートしたデータをインポートする場合は、次の手順を実行します。

.jsonファイルをコンテナインスタンスの`import`フォルダーにコピーします。

`scp your-group-data.json username@some-domain.org:loomio-deploy/import`

実行中のRailsコンソールにアクセスします。

`docker exec -ti loomio-app rails console`

サービスを呼び出します。

`GroupExportService.import('/import/your-group-data.json')`
