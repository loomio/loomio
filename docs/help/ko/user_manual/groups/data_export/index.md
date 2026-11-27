---
sections:
  introduction: 988679ffd3d29834
  export-data: '024783a0614721d2'
  export-group-data-as-csv: c0845f09bff828f2
  export-group-data-as-html: 659fd5e14956b00e
  export-group-data-as-json: 4c2131f4518b7469
  print-thread-to-pdf: 1a1d0598f4277ba1
  import-your-group-data-on-another-loomio-server: 33d49c6c25be163b
generated:
  introduction: 65c415b618e3a305
  export-data: acf57d2e25656ba0
  export-group-data-as-csv: 644f1b52219789d4
  export-group-data-as-html: 464d78fcaa7b0541
  export-group-data-as-json: 3b28394d0738effa
  print-thread-to-pdf: 828ce33cb8420678
  import-your-group-data-on-another-loomio-server: f4d2586a8dabd07b
title: 데이터 내보내기
title_source: 29049648f87b87f5
title_generated: 91ea82c131b0a78b
source_revision: 6e7aad6a91a50e55dca43a20edcc88d445ee4185
source_file: docs/help/en/user_manual/groups/data_export/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-11-26'
---

<!-- translation-section: introduction -->

# 그룹 데이터 백업 또는 내보내기

그룹 데이터 내보내기 기능으로 다음 작업을 할 수 있습니다.

- 멤버 데이터를 다운로드하여 그룹의 멤버 현황을 점검합니다.
- 그룹의 스레드, 댓글, 투표를 보관하거나 분석합니다.
- 스프레드시트나 스크립트로 투표 결과를 엽니다.
- [기록으로 보관할 수 있도록 스레드나 투표를 인쇄하거나 PDF로 저장합니다.](#print-thread-to-pdf)
- 사용자, 스레드, 투표, 파일을 포함한 그룹을 다른 Loomio 서버로 이전합니다.

이 기능을 사용하여 Loomio의 호스팅 서비스에서 [직접 운영하는 서버](https://github.com/loomio/loomio)로 이전할 수 있습니다. 직접 서버를 운영하고 있으며 미국, EU 또는 호주에 있는 Loomio의 관리형 호스팅으로 이전하려면 [문의하세요](/contact).

loomio.com에서 지역별 서비스인 유럽용 loomio.eu 또는 호주 및 뉴질랜드용 loomio.nz로 그룹을 이전하려면 [문의하세요](/contact).

<!-- translation-section: export-data -->

## 데이터 내보내기

그룹 관리자만 그룹 데이터를 내보낼 수 있습니다. 그룹 페이지에서 **설정**을 열고 **그룹 데이터 내보내기**를 선택하세요.

![Oatmilk Cooperative 설정 페이지의 그룹 데이터 내보내기 항목](group_export_group_data.png)

Loomio는 백그라운드에서 내보내기를 준비하고, 준비가 완료되면 다운로드 링크를 이메일로 보냅니다. 링크는 일주일 동안 사용할 수 있습니다.

<!-- translation-section: export-group-data-as-csv -->

### 그룹 데이터를 CSV로 내보내기

Microsoft Excel이나 Google Sheets 같은 스프레드시트에서 멤버의 세부 정보와 활동을 포함한 그룹 데이터를 살펴보려면 CSV를 사용하세요.

<!-- translation-section: export-group-data-as-html -->

### 그룹 데이터를 HTML로 내보내기

그룹의 토론과 투표를 읽을 수 있는 형태로 저장하여 보관하려면 HTML을 사용하세요.

<!-- translation-section: export-group-data-as-json -->

### 그룹 데이터를 JSON으로 내보내기

직접 호스팅하는 Loomio 서버로 그룹 데이터를 이전하려면 JSON을 사용하세요.

JSON 내보내기에는 다음 항목이 포함됩니다.

- 그룹, 해당 그룹의 멤버와 가입 요청
- 포함된 그룹의 스레드, 댓글, 반응, 태그, 템플릿, 알림 및 관련 기록
- 투표, 선택지, 표 및 결론. 익명 투표는 마감된 후에만 포함됩니다.
- 소속된 하위 그룹
- 상위 그룹 관리자로서 상위 그룹을 내보내는 경우, 소속되지 않은 하위 그룹이라도 공개, 비공개, 상위 그룹에 표시되는 하위 그룹
- 포함된 콘텐츠에 첨부된 파일과 이미지의 참조 정보

JSON 내보내기에는 다음 항목이 포함되지 않습니다.

- 소속되지 않은 비밀 하위 그룹과 해당 하위 그룹의 멤버 정보 및 콘텐츠
- 삭제 대기 중인 하위 그룹
- 마감되지 않은 익명 투표
- 그룹에 속하지 않은 다이렉트 스레드와 투표

<!-- translation-section: print-thread-to-pdf -->

## 스레드를 PDF로 인쇄하기

스레드 하나를 기록으로 보관하려면 해당 스레드의 작업 메뉴를 열고 **인쇄**를 선택하세요. Loomio는 스레드의 댓글, 투표, 표, 결론 및 서식이 포함된 HTML 페이지를 생성합니다. 브라우저의 인쇄 도구로 인쇄하거나 PDF로 저장하세요. 또는 콘텐츠를 복사하여 다른 문서에 붙여넣으세요.

![반환용 병에 관한 토론의 인쇄 항목](discussion_print_discussion.png#width-90)

<!-- translation-section: import-your-group-data-on-another-loomio-server -->

## 다른 Loomio 서버로 그룹 데이터 가져오기

이 섹션은 직접 호스팅하는 Loomio 서버를 운영하는 관리자를 위한 안내입니다. 설정 방법은 [Loomio 저장소](https://github.com/loomio/loomio)를 참고하세요.

1. `.json` 파일을 컨테이너의 `import` 폴더로 복사하세요.

```sh
scp your-group-data.json username@some-domain.org:loomio-deploy/import
```

2. 실행 중인 컨테이너에서 Rails 콘솔을 여세요.

```sh
docker exec -ti loomio-app rails console
```

3. 가져오기 서비스를 실행하세요.

```ruby
GroupExportService.import('/import/your-group-data.json')
```
