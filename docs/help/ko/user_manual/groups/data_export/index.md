---
sections:
  introduction: 5e29f67f9a2084ec
  export-data: 58b5e1d4e6f0b917
  export-group-data-as-csv: 53286ec33e7300d6
  export-group-data-as-html: 101671937dcd6f36
  export-group-data-as-json: aa310889d0854550
  print-thread-to-pdf: a0ad78b64036be18
  import-your-group-data-on-another-loomio-server: 910ee8af48049e82
generated:
  introduction: 00a2235c1b5e97e5
  export-data: f659f9f424cf2048
  export-group-data-as-csv: '0814bc8beb6ee4e0'
  export-group-data-as-html: 218f4ca6406aaab0
  export-group-data-as-json: c373ebd43979b733
  print-thread-to-pdf: 1d82a5b145339aec
  import-your-group-data-on-another-loomio-server: 8802c0cb8979b375
title: 데이터 내보내기
title_source: 29049648f87b87f5
title_generated: 91ea82c131b0a78b
source_revision: 5d6c305d2dfb5c47f5a90b1c1e6658ca352d88f5
source_file: docs/help/en/user_manual/groups/data_export/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-11-09'
---

<!-- translation-section: introduction -->

# 그룹 데이터 백업 또는 내보내기

그룹 데이터 내보내기 기능으로 다음 작업을 할 수 있습니다.

- 멤버 데이터가 포함된 파일을 다운로드하여 그룹의 멤버 현황을 점검합니다.
- 보관하거나 분석할 수 있도록 스레드와 투표의 텍스트를 포함한 그룹 콘텐츠를 다운로드합니다.
- 스프레드시트나 스크립트 언어로 투표 결과를 엽니다.
- [보관할 수 있도록 스레드나 투표를 인쇄하거나 PDF로 저장합니다.](#print-thread-to-pdf)
- 모든 사용자, 스레드, 투표, 파일을 포함한 그룹을 다른 Loomio 서버로 이전합니다.

Loomio가 관리하는 서버에서 [직접 운영하는 서버로](https://github.com/loomio/loomio) 이전하려면 이 기능을 사용할 수 있습니다.

직접 Loomio 서버를 운영하고 있지만 더 이상 운영하고 싶지 않다면, Loomio가 미국, EU, 호주에서 제공하는 관리형 호스팅을 이용할 수 있습니다. 이 서버 중 하나로 그룹을 이전하려면 [문의하세요](/contact).

loomio.com의 Loomio 글로벌 호스팅 서비스에서 지역별 서비스인 유럽용 loomio.eu 또는 호주 및 뉴질랜드용 loomio.nz로 Loomio 그룹을 이전하려면 [문의하세요](/contact).

<!-- translation-section: export-data -->

## 데이터 내보내기

점 세 개를 클릭하여 그룹 드롭다운 메뉴를 열고 **그룹 데이터 내보내기**를 선택하세요.

![Oatmilk Cooperative 메뉴의 그룹 데이터 내보내기 항목](group_export_group_data.png)

<!-- translation-section: export-group-data-as-csv -->

### 그룹 데이터를 CSV로 내보내기

*MS Excel이나 Google Sheets 같은 스프레드시트에서 그룹 데이터로 작업할 때 사용합니다.*

Loomio는 백그라운드에서 CSV 파일을 준비하고, 준비가 완료되면 다운로드 링크를 이메일로 보냅니다. 링크는 일주일 동안 사용할 수 있습니다.

<!-- translation-section: export-group-data-as-html -->

### 그룹 데이터를 HTML로 내보내기

*보관 목적으로 데이터를 저장할 때 사용합니다.*

Loomio는 백그라운드에서 HTML 파일을 준비하고, 준비가 완료되면 다운로드 링크를 이메일로 보냅니다. 링크는 일주일 동안 사용할 수 있습니다.

<!-- translation-section: export-group-data-as-json -->

### 그룹 데이터를 JSON으로 내보내기

*직접 호스팅하는 Loomio 인스턴스로 그룹 데이터를 이전할 때 사용합니다.*

그룹 데이터를 내보내려면 그룹 관리자여야 합니다. JSON 내보내기에는 다음 항목이 포함됩니다.

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

잠시 후 JSON 파일을 다운로드할 수 있는 링크가 포함된 이메일을 받게 됩니다.

<!-- translation-section: print-thread-to-pdf -->

## 스레드를 PDF로 인쇄하기

스레드를 기록으로 보관하려면 스레드 메뉴를 열고 **인쇄**를 선택하세요. Loomio는 스레드의 댓글, 투표, 표, 결론 및 서식이 포함된 HTML 페이지를 생성합니다. 브라우저의 인쇄 도구를 사용하여 인쇄하거나 PDF로 저장하세요.

페이지를 복사하여 문서 편집기, 파일 또는 데이터 저장소에 붙여넣을 수 있습니다.

![반환용 병에 관한 토론의 인쇄 항목](discussion_print_discussion.png#width-90)

<!-- translation-section: import-your-group-data-on-another-loomio-server -->

## 다른 Loomio 서버로 그룹 데이터 가져오기

Loomio 서버를 직접 설정하는 방법은 다음 페이지를 참고하세요: https://github.com/loomio/loomio

Loomio를 직접 호스팅하고 있으며 내보낸 데이터를 가져오려면 다음 단계를 따르세요.

.json 파일을 컨테이너 인스턴스의 `import` 폴더로 복사하세요.

`scp your-group-data.json username@some-domain.org:loomio-deploy/import`

실행 중인 Rails 콘솔에 접속하세요.

`docker exec -ti loomio-app rails console`

서비스를 호출하세요.

`GroupExportService.import('/import/your-group-data.json')`
