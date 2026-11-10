---
sections:
  introduction: 33c4ce1c59342826
  authentication: a215188bb0ae2b38
  provisioning: de7ad238bf914455
  user-object: 7e9e8ff3e48a4055
  list-users: 16e557db2983e597
  example: 5a370a67d3dc961f
  show-user: ef061aab9e142a98
  examples: 5b98557c8af42e29
  update-user: fc52abc60aa4eb6e
  params: 368f797e2a2b5c3d
  examples-2: b6bc03ca1e104210
  deactivate-user: 19c9b37ded7cad07
  examples-3: 706a02fb50225d20
  reactivate-user: 03bccb45ded4f11c
  examples-4: 5c9cf19d21267502
  redact-user: 9560a30820cb43cc
  examples-5: df81d06971fb0391
  delete-user: 1aad5e4da586e0ed
  examples-6: 23542029b0bc8237
  sso-profile-sync-settings: 416144004d040e4f
generated:
  introduction: 3de3a33cb5dc333f
  authentication: 0d7a7a4575c1801f
  provisioning: 54f2e595314764ae
  user-object: 0f2d51f468adbfdf
  list-users: b1f74d2f2b5faa85
  example: 394c82e3692aa01b
  show-user: '084a302358dbbeae'
  examples: 59e172d7be402e11
  update-user: b87ccc1e2a2d18a6
  params: af57242bdf50e5c2
  examples-2: b00d0d328f215170
  deactivate-user: 9f7cd1dc1bdf346f
  examples-3: 97e748600693e1f6
  reactivate-user: 0efcbc47d32f9000
  examples-4: 7bbafe6540cf6afb
  redact-user: e2eee035b8b1bc18
  examples-5: 240031567bf9876f
  delete-user: 525485960a0b9ecb
  examples-6: 021e44125c1e6b9b
  sso-profile-sync-settings: 26d09375b6f3c214
title: 서버 API
title_source: 370e81eb20eece44
title_generated: bb1f879f5240879d
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-11-09'
source_revision: 5d6c305d2dfb5c47f5a90b1c1e6658ca352d88f5
source_file: docs/help/en/user_manual/integrations/api/server-api.md
---

<!-- translation-section: introduction -->

# Loomio 서버 API 문서

<!-- seo-description: Loomio 서버 API로 자체 호스팅 Loomio 설치 환경에서 사용자 계정을 생성하고, 그룹을 조회하고, 멤버 자격을 관리하세요. -->

`/api/server0`은 서버 수준 작업에 사용합니다. Loomio 사용자 계정으로 수행하는 사용자 중심 작업에는 `/api/user0`을 사용하세요.

서버 키 하나로 계정을 생성하고 관리하며, 설치 환경 전체의 그룹을 조회하고, 해당 그룹의 멤버 자격과 역할을 관리할 수 있습니다. 봇 계정, 사용자 API 키 또는 해당 그룹의 멤버 자격은 필요하지 않습니다. 사용자 API 키에는 계속해서 해당 사용자의 그룹 권한이 적용됩니다.

<!-- translation-section: authentication -->

## 인증

키는 서버 환경의 `SERVER_API_KEY` 설정값입니다. 새로 설치할 때는 `create_env.sh`가 키를 생성합니다.

키를 Bearer 토큰으로 전송하세요.

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users
```

인증 정보는 `Authorization` 헤더로만 전송하세요. 쿼리 문자열이나 요청 본문에 포함된 API 키는 거부됩니다.

<!-- translation-section: provisioning -->

## 계정 및 멤버 자격 생성과 관리

| 메서드 | 엔드포인트 | 용도 |
| --- | --- | --- |
| `POST` | `/api/server0/users` | 계정 생성 |
| `GET` | `/api/server0/groups` | 설치 환경 전체의 그룹 조회 |
| `GET` | `/api/server0/memberships` | 그룹의 멤버 자격 목록 조회 |
| `POST` | `/api/server0/memberships` | 멤버 초대 또는 전체 멤버 목록 동기화 |
| `PATCH` | `/api/server0/memberships/:id` | 그룹 관리자 및 대리인 역할 변경 |
| `DELETE` | `/api/server0/memberships/:id` | 멤버 자격 하나 취소 |

기존 계정의 수정, 비활성화, 재활성화, 개인정보 삭제 및 계정 삭제 엔드포인트는 아래에서 설명합니다.

### 계정 생성

`POST /api/server0/users`

필수 필드인 `email`을 포함한 `user` 객체를 전송하세요. 이메일 주소의 앞뒤 공백은 제거되고 소문자로 변환됩니다. 선택 필드는 `name`, `username`, `is_admin`입니다. 여기서 `is_admin`은 인스턴스 관리자를 의미하며, 그룹 관리자 역할은 멤버 자격에서 관리합니다. `username`을 생략하면 자동으로 생성됩니다. 알 수 없는 필드는 거부됩니다.

```bash
curl https://loomio.example.org/api/server0/users \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY' \
  --json '{
    "user": {
      "email": "ada@example.org",
      "name": "Ada Lovelace",
      "username": "ada",
      "is_admin": false
    }
  }'
```

응답은 `user` 객체를 포함한 HTTP `201`입니다. 필드가 유효하지 않거나 이메일 또는 사용자명이 이미 사용 중이면 HTTP `422`를 반환합니다. 계정을 생성해도 초대가 발송되거나, 사용자가 로그인되거나, 이메일이 인증된 것으로 표시되지는 않습니다. 일반 알림 절차를 통해 초대를 보내려면 멤버 자격 엔드포인트를 사용하여 그룹에 초대하세요.

### 그룹 조회

`GET /api/server0/groups`

비공개 그룹과 구독이 만료된 그룹을 포함하여 삭제되지 않은 모든 그룹을 조회합니다. 결과는 ID 오름차순으로 정렬됩니다. 페이지를 나누어 조회하려면 `limit`(기본값 및 최댓값 `50`)과 `offset`(기본값 `0`)을 사용하세요.

```bash
curl 'https://loomio.example.org/api/server0/groups?limit=50&offset=0' \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY'
```

```json
{
  "groups": [
    {
      "id": 123,
      "key": "examplegroup",
      "name": "Planning group",
      "handle": "planning",
      "parent_id": null,
      "group_privacy": "secret"
    }
  ],
  "meta": {
    "total": 1
  }
}
```

### 멤버 자격 목록 조회

`GET /api/server0/memberships?group_id=123`

`group_id`는 필수입니다. 결과에는 수락된 멤버 자격과 대기 중인 초대가 포함되며, 멤버 자격 ID 오름차순으로 정렬됩니다. 취소된 멤버 자격은 제외됩니다. 페이지를 나누어 조회하려면 `limit`(기본값 및 최댓값 `50`)과 `offset`(기본값 `0`)을 사용하세요.

```bash
curl 'https://loomio.example.org/api/server0/memberships?group_id=123&limit=50&offset=0' \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY'
```

```json
{
  "memberships": [
    {
      "id": 456,
      "group_id": 123,
      "user_id": 789,
      "user_email": "ada@example.org",
      "user_name": "Ada Lovelace",
      "admin": false,
      "delegate": false,
      "accepted_at": null,
      "pending": true
    }
  ],
  "meta": {
    "total": 1
  }
}
```

`admin`과 `delegate`는 그룹 역할입니다. `accepted_at`은 수락 시각이며, 초대가 대기 중일 때는 `null`입니다. 이 엔드포인트는 초대 토큰, 로그인 인증 정보 또는 개별 표를 노출하지 않습니다.

### 멤버 초대 또는 동기화

`POST /api/server0/memberships`

필수 항목인 `group_id`와 `emails` 배열을 전송하세요. 기본적으로 목록에 있는 사람 중 활성 멤버 자격이 없는 사람을 추가하며, 다른 멤버는 그대로 유지합니다. 이메일 주소의 앞뒤 공백은 제거되고 소문자로 변환되며 중복이 제거됩니다. 새 주소에 대해서는 계정과 대기 중인 초대가 생성됩니다. 같은 조직 내 다른 활성 그룹에 속한 기존 멤버 중 이메일이 인증된 멤버는 사용자 API의 초대 절차와 동일하게 자동으로 수락 처리됩니다.

```bash
curl https://loomio.example.org/api/server0/memberships \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY' \
  --json '{
    "group_id": 123,
    "emails": [
      "ada@example.org",
      "alex@example.org"
    ]
  }'
```

전체 멤버 목록을 동기화하려면 `remove_absent`를 명시적으로 `true`로 설정하세요. 목록에 없는 사람은 해당 그룹과 하위 그룹에서 제거됩니다. 빈 배열과 함께 `remove_absent: true`를 전송하면 그룹 관리자를 포함한 모든 사람이 제거됩니다. 사람을 추가하기만 할 때는 `remove_absent`를 생략하거나 `false`로 설정하세요. 이전 형식의 값인 `1`과 `0`도 허용됩니다.

```bash
curl https://loomio.example.org/api/server0/memberships \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY' \
  --json '{
    "group_id": 123,
    "emails": [
      "ada@example.org"
    ],
    "remove_absent": true
  }'
```

```json
{
  "added_emails": [],
  "removed_emails": [
    "alex@example.org"
  ]
}
```

같은 요청을 반복해도 멤버 자격이 중복 생성되거나 초대가 다시 발송되지 않습니다. 멤버 자격이 취소된 멤버를 다시 초대하면 그룹 접근 권한은 복구되지만 이전 관리자 역할은 복구되지 않습니다. 새 초대와 역할 변경에는 일반 알림 절차가 적용되며, 작업을 수행한 사용자로 기록되는 사람은 없습니다.

이메일 목록이 누락되었거나 형식이 잘못된 경우 또는 불리언 값이 유효하지 않은 경우 HTTP `400`을 반환합니다. 목록에 비활성화된 계정이 있으면 HTTP `422`를 반환하므로, 추가하기 전에 해당 계정을 명시적으로 재활성화하세요. 유효하지 않은 계정 데이터, 구독 한도 또는 기타 오류가 발생하면 새 계정 생성과 멤버 자격 제거를 포함한 전체 동기화가 롤백됩니다. 멤버를 추가하려면 그룹이 활성 상태여야 하며, 구독의 멤버 수 한도도 적용됩니다.

### 멤버 자격의 역할 수정

`PATCH /api/server0/memberships/:id`

불리언 필드인 `admin`과 `delegate` 중 하나 또는 둘 다 포함한 `membership` 객체를 전송하세요. 생략한 역할은 변경되지 않습니다. 알 수 없는 필드는 거부됩니다. 이 엔드포인트로는 멤버 자격을 이전하거나, 초대를 수락하거나, 투표 가중치를 변경할 수 없습니다.

```bash
curl https://loomio.example.org/api/server0/memberships/456 \
  -X PATCH \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY' \
  --json '{
    "membership": {
      "admin": true,
      "delegate": false
    }
  }'
```

목록 조회 시와 동일한 필드를 가진 `membership` 객체를 반환합니다. 역할을 부여하면 일반적인 역할 알림이 생성됩니다. 역할이 변경되지 않는 요청을 반복해도 알림이 다시 발송되지 않습니다. 역할을 변경하려면 그룹이 활성 상태여야 합니다. 취소된 멤버 자격에 대해서는 HTTP `404`를 반환합니다.

### 멤버 자격 하나 제거

`DELETE /api/server0/memberships/:id`

```bash
curl https://loomio.example.org/api/server0/memberships/456 \
  -X DELETE \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY'
```

`{"success": true}`를 반환합니다. 제거하면 해당 그룹과 하위 그룹의 접근 권한이 취소되며, 여기에는 주제 접근 권한과 진행 중인 투표의 투표권이 포함됩니다. 계정을 삭제하거나, 관련 없는 그룹을 변경하거나, 스레드에 직접 부여된 접근 권한을 제거하지는 않습니다. 제거 요청을 반복해도 성공합니다. 구독이 만료된 그룹에서도 멤버 자격을 제거할 수 있습니다. 삭제된 그룹에 대해서는 HTTP `404`를 반환합니다.

<!-- translation-section: user-object -->

## 사용자 객체

사용자 응답은 다음 구조를 사용합니다.

```json
{
  "id": 123,
  "name": "Ada Lovelace",
  "username": "ada",
  "email": "ada@example.org",
  "is_admin": false,
  "active": true,
  "deactivated_at": null,
  "identities": [
    {
      "id": 456,
      "identity_type": "oauth",
      "uid": "external-123",
      "email": "ada@example.org",
      "name": "Ada Lovelace"
    }
  ]
}
```

<!-- translation-section: list-users -->

## 사용자 목록 조회

Loomio 설치 환경의 모든 사용자 계정을 조회합니다.

`GET /api/server0/users`

<!-- translation-section: example -->

### 예시

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users
```

반환값:

```json
{
  "users": []
}
```

<!-- translation-section: show-user -->

## 사용자 조회

Loomio 사용자 ID 또는 외부 식별 정보로 사용자를 찾습니다.

`GET /api/server0/users/:id`

`GET /api/server0/users/identity/:identity_type/:uid`

<!-- translation-section: examples -->

### 예시

Loomio 사용자 ID로 조회:

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/123
```

외부 식별 정보로 조회:

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/identity/oauth/external-123
```

반환값:

```json
{
  "user": {}
}
```

<!-- translation-section: update-user -->

## 사용자 수정

Loomio 사용자 ID 또는 외부 식별 정보로 찾은 사용자의 프로필 필드를 수정합니다.

`PATCH /api/server0/users/:id`

`PATCH /api/server0/users/identity/:identity_type/:uid`

<!-- translation-section: params -->

### 매개변수

| 필드 | 설명 |
| --- | --- |
| `name` | 표시 이름 |
| `username` | Loomio 사용자명 |
| `email` | 이메일 주소 |

<!-- translation-section: examples-2 -->

### 예시

Loomio 사용자 ID로 수정:

```bash
curl -X PATCH \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"user":{"name":"Ada Lovelace","username":"ada","email":"ada@example.org"}}' \
  https://www.loomio.com/api/server0/users/123
```

외부 식별 정보로 수정:

```bash
curl -X PATCH \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"user":{"name":"Ada Lovelace","username":"ada","email":"ada@example.org"}}' \
  https://www.loomio.com/api/server0/users/identity/oauth/external-123
```

수정된 사용자를 반환합니다.

```json
{
  "user": {}
}
```

<!-- translation-section: deactivate-user -->

## 사용자 비활성화

Loomio 사용자 ID 또는 외부 식별 정보로 찾은 사용자 계정을 비활성화합니다.

`POST /api/server0/users/:id/deactivate`

`POST /api/server0/users/identity/:identity_type/:uid/deactivate`

<!-- translation-section: examples-3 -->

### 예시

Loomio 사용자 ID로 조회:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/123/deactivate
```

외부 ID로 조회:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/identity/oauth/external-123/deactivate
```

응답:

```json
{
  "success": true,
  "user": {}
}
```

<!-- translation-section: reactivate-user -->

## 사용자 재활성화

Loomio 사용자 ID 또는 외부 ID로 찾은 비활성화된 사용자 계정을 재활성화합니다.

`POST /api/server0/users/:id/reactivate`

`POST /api/server0/users/identity/:identity_type/:uid/reactivate`

<!-- translation-section: examples-4 -->

### 예시

Loomio 사용자 ID로 조회:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/123/reactivate
```

외부 ID로 조회:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/identity/oauth/external-123/reactivate
```

응답:

```json
{
  "success": true,
  "user": {}
}
```

<!-- translation-section: redact-user -->

## 사용자 개인정보 삭제

개인정보 삭제는 사용자의 댓글과 그 밖에 사용자가 작성한 콘텐츠를 그룹 내에 유지하면서 이름, 소개, 프로필 사진, 이메일 주소, 로그인 인증 정보, 외부 ID, 활성 세션 등 알려진 개인 식별 정보를 삭제합니다.

Loomio에서 사용자를 제거할 때는 이 방법을 권장합니다.

`POST /api/server0/users/:id/redact`

`POST /api/server0/users/identity/:identity_type/:uid/redact`

<!-- translation-section: examples-5 -->

### 예시

Loomio 사용자 ID로 조회:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/123/redact
```

외부 ID로 조회:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/identity/oauth/external-123/redact
```

응답:

```json
{
  "success": true
}
```

<!-- translation-section: delete-user -->

## 사용자 삭제

삭제는 사용자와 사용자가 생성한 기록을 제거합니다. 스레드에서 댓글이 삭제되고 투표에서 해당 사용자의 표가 삭제되며, 사용자가 생성한 그룹, 토론, 투표 및 기타 기록도 데이터베이스의 연관 관계에 따라 삭제될 수 있습니다.

이 작업은 많은 데이터를 삭제합니다. 대신 개인정보 삭제를 사용할 것을 강력히 권장합니다.

`DELETE /api/server0/users/:id`

`DELETE /api/server0/users/identity/:identity_type/:uid`

<!-- translation-section: examples-6 -->

### 예시

Loomio 사용자 ID로 조회:

```bash
curl -X DELETE -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/123
```

외부 ID로 조회:

```bash
curl -X DELETE -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/identity/oauth/external-123
```

응답:

```json
{
  "success": true
}
```

<!-- translation-section: sso-profile-sync-settings -->

## SSO 프로필 동기화 설정

다른 시스템에서 Loomio 프로필 필드를 관리할 때 이 설정을 사용하세요.

```env
LOOMIO_DISABLE_EDIT_USER_PROFILE=1
# LOOMIO_SSO_UPDATE_USER_PROFILE_ON_LOGIN=1
```

`LOOMIO_DISABLE_EDIT_USER_PROFILE=1`은 사용자가 다음 필드를 직접 수정하지 못하게 합니다.

| 필드 | 설명 |
| --- | --- |
| `name` | 외부 동기화로 관리 |
| `username` | 외부 동기화로 관리 |
| `email` | 외부 동기화로 관리 |
| `avatar_kind` / `uploaded_avatar` | 외부 동기화로 관리 |

사용자는 `short_bio`, `location` 등 Loomio 내부에서만 사용하는 필드를 계속 수정할 수 있습니다.

`LOOMIO_SSO_UPDATE_USER_PROFILE_ON_LOGIN=1`은 SSO 로그인 데이터로 `name`과 `email`을 업데이트합니다. 외부 동기화 스크립트만 이 필드를 업데이트해야 하는 경우에는 이 설정을 주석 처리한 상태로 두거나 설정하지 마세요.

`LOOMIO_SSO_FORCE_USER_ATTRS`는 기존 설치 환경에서도 계속 작동합니다. 이 설정은 사용자의 수정을 차단하고 SSO 로그인 시 `name`과 `email`을 업데이트합니다.
