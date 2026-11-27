---
title: データのエクスポート
source_revision: 6e7aad6a91a50e55dca43a20edcc88d445ee4185
source_file: docs/help/en/user_manual/groups/data_export/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-11-26'
sections:
  introduction: 988679ffd3d29834
  export-data: '024783a0614721d2'
  export-group-data-as-csv: c0845f09bff828f2
  export-group-data-as-html: 659fd5e14956b00e
  export-group-data-as-json: 4c2131f4518b7469
  print-thread-to-pdf: 1a1d0598f4277ba1
  import-your-group-data-on-another-loomio-server: 33d49c6c25be163b
generated:
  introduction: 0b4a90e663b3aaf8
  export-data: '0915b36f4b4ebcf7'
  export-group-data-as-csv: c0ced6f60fcff34f
  export-group-data-as-html: ca4b1e5171118727
  export-group-data-as-json: da0f561d2a329858
  print-thread-to-pdf: 607702321e8254f7
  import-your-group-data-on-another-loomio-server: dc2a0eba5f0b4831
title_source: 29049648f87b87f5
title_generated: e8a1a8a6aba2c93d
---

<!-- translation-section: introduction -->

# グループデータのバックアップまたはエクスポート

グループデータのエクスポートでは、次のことができます。

- メンバーのデータをダウンロードして、グループのメンバー構成を確認できます。
- グループのスレッド、コメント、アンケートを保管したり分析したりできます。
- アンケートの結果を表計算ソフトやスクリプトで開けます。
- [記録用にスレッドやアンケートを印刷したり、PDFとして保存したりできます。](#print-thread-to-pdf)
- ユーザー、スレッド、アンケート、ファイルを含むグループを、別のLoomioサーバーに移行できます。

Loomioのホスティングサービスから[セルフホストのサーバー](https://github.com/loomio/loomio)へ移行する場合に、この機能を利用できます。独自のサーバーを運用していて、米国、EU、オーストラリアにあるLoomioのマネージドホスティングへ移行したい場合は、[お問い合わせください](/contact)。

loomio.comから地域別サービス（ヨーロッパ向けのloomio.eu、またはオーストラリアとニュージーランド向けのloomio.nz）へグループを移行したい場合は、[お問い合わせください](/contact)。

<!-- translation-section: export-data -->

## データのエクスポート

グループデータをエクスポートできるのは、グループ管理者のみです。グループページで**設定**を開き、**グループデータのエクスポート**を選択します。

![Oatmilk Cooperativeの設定ページにあるグループデータのエクスポート操作](group_export_group_data.png)

Loomioはバックグラウンドでエクスポートの準備を進め、準備ができるとダウンロードリンクをメールで送信します。リンクは1週間利用できます。

<!-- translation-section: export-group-data-as-csv -->

### グループデータをCSVとしてエクスポート

メンバーの詳細や活動を含むグループデータをMicrosoft ExcelやGoogle Sheetsなどの表計算ソフトで確認するには、CSVを使用します。

<!-- translation-section: export-group-data-as-html -->

### グループデータをHTMLとしてエクスポート

グループのディスカッションやアンケートを読みやすい形式で保管するには、HTMLを使用します。

<!-- translation-section: export-group-data-as-json -->

### グループデータをJSONとしてエクスポート

グループデータをセルフホストのLoomioサーバーへ移行するには、JSONを使用します。

JSONエクスポートには次のものが含まれます。

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

<!-- translation-section: print-thread-to-pdf -->

## スレッドをPDFとして印刷

1つのスレッドを記録として保存するには、スレッドの操作メニューを開き、**印刷する**を選択します。Loomioが、スレッドのコメント、アンケート、投票、結論、書式を含むHTMLページを生成します。ブラウザーの印刷機能を使って印刷するかPDFとして保存するか、コンテンツを別の文書にコピーします。

![リターナブル瓶についてのディスカッションの印刷操作](discussion_print_discussion.png#width-90)

<!-- translation-section: import-your-group-data-on-another-loomio-server -->

## 別のLoomioサーバーにグループデータをインポート

このセクションは、セルフホストのLoomioサーバーを運用する管理者向けです。セットアップ手順は、[Loomioリポジトリ](https://github.com/loomio/loomio)をご覧ください。

1. `.json`ファイルをコンテナの`import`フォルダーにコピーします。

```sh
scp your-group-data.json username@some-domain.org:loomio-deploy/import
```

2. 実行中のコンテナでRailsコンソールを開きます。

```sh
docker exec -ti loomio-app rails console
```

3. インポートサービスを実行します。

```ruby
GroupExportService.import('/import/your-group-data.json')
```
