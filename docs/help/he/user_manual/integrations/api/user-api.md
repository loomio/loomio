---
title: API למשתמש
source_revision: 28ecc59f68d407f76f08133bfa0172aadbb53065
source_file: docs/en/user_manual/integrations/api/user-api.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-15'
sections:
  introduction: b6e6ec7463276869
  response-size-and-related-records: 298da635bf97dadd
  endpoint-summary: 258f7560def524ec
  groups: 0473f1f7fb78f074
  list-groups: 01de10c378eeba37
  get-a-group: dffef659cb92745e
  webhooks: f65fa289f8c1b808
  list-webhooks: 6093df92815f7156
  create-a-webhook: 007312bcc204853a
  update-a-webhook: 124b07d2c401e319
  test-a-webhook-destination: 8fc3ac4ad10de6f6
  delete-a-webhook: 34eda1e07d65db80
  event-types: 73bfe87c8b790af3
  http-delivery: a32c763b6f816e65
  payload-formats: ca728b0ef542305c
  search: bb5a1cfc7a6179aa
  params: 7eebe4e259830976
  participation-report: a1798112a78390fe
  params-2: 464322ffc1ac56e5
  example: 63bed6e82107f992
  create-discussion: 958fc684640462a9
  params-3: 657d582c89333097
  example-2: 57681d83fffe9515
  show-discussion: 40102aeffe4f1286
  example-3: c0ebd013a1b7fbd2
  list-discussions: '09ff7f0d3a937b41'
  params-4: dcebc294fbb9d837
  example-4: ffda1a4726380e2f
  list-threads: '09f7bd670e581400'
  params-5: 79b1cefac558effc
  example-5: a40ae2317faab46d
  read-thread: ac36d1b81c1eeed4
  example-6: 8c582a286e04ca75
  edit-discussion: 918161e7aa8f4aa6
  params-6: b819796d34354623
  example-7: 552295f78d3490af
  soft-delete-discussion: c8ffe951171e6f07
  example-8: 965c5761f34f9920
  create-comment: f95f56b81c8f22b5
  params-7: 5ad8ede0919c5f47
  example-9: 70ee3750f1543e9b
  edit-comment: 80322da74162d58f
  params-8: 288331c60f3c9b28
  example-10: ec89de8cc86b6fc8
  soft-delete-comment: 04baf86923c7e8f1
  example-11: f3675b780da755cd
  create-poll: cf62e787784a5e87
  params-9: df1611a9dedef2d8
  example-12: fa7410dd3a0a385f
  show-poll: d759508986aab08c
  example-13: 2867289a6c2beb9d
  list-polls: 56e5ed4ae45e5428
  params-10: e68e8cf62b21488d
  example-14: 40958a09c058d4cc
  edit-poll: 65467ad0b431ddbf
  params-11: 77f118397592bc05
  example-15: e56befa0f2ae3360
  soft-delete-poll: 61cf76310e08d7ff
  example-16: afbf95df96734a4d
  list-memberships: 5fab06bb8ecf1fd0
  params-12: decaff0790566fb0
  example-17: 5d92092b70ce545a
  manage-memberships: 802d39c06674d395
  params-13: 771b5338a4ba3d0b
  example-18: a50b01823a6935a0
  pagination: 4171ca78df07d4fe
  comments: ccd37303241bac95
  discussions: 16ffe7a7b6202d3e
  memberships: e7cf8846c3179720
  polls: 821dcd89b5460804
  threads: 19bc02fc1c26317b
generated:
  introduction: 61da915570c17551
  response-size-and-related-records: 27c064f744d02ba9
  endpoint-summary: cb242eb9f03d650d
  groups: 05c42ae402e79755
  list-groups: a50183e896be693c
  get-a-group: 8bd2ae664cbaaa38
  webhooks: 14d9495f3dd01876
  list-webhooks: f5058c3e85e22e4e
  create-a-webhook: 78bc78be024b8420
  update-a-webhook: 9e7f676f89442a2b
  test-a-webhook-destination: 3a697f85b2c57177
  delete-a-webhook: 4622a98c33aa3ad1
  event-types: '056208c56ab55520'
  http-delivery: '08e26e82a2762362'
  payload-formats: f696dd3d78b73996
  search: af527b3194a4f8eb
  params: d4bd40bc7b6535f1
  participation-report: 435d724bed926ca7
  params-2: c6e14c4bc724415e
  example: a231af52382ab4b4
  create-discussion: 312ff346dcbefefa
  params-3: 14b08be2d757109a
  example-2: 57a5e6806766a598
  show-discussion: 43ad037e46ec057a
  example-3: '07390f7ec4c0ac0b'
  list-discussions: '0451588db76d956e'
  params-4: fab9d716a09ad713
  example-4: dcf3db406159f0f2
  list-threads: f607b813290ecb90
  params-5: 44b8ceccc73fc51c
  example-5: df03b4198a819289
  read-thread: 5ac7e4cd23c52bc2
  example-6: 6aec10cf3792a7d4
  edit-discussion: 64af711063115414
  params-6: d5f5de6310baa465
  example-7: 1a5b8d50f9c0c332
  soft-delete-discussion: 0b8f631efdb5dc5a
  example-8: c42726e4509f6682
  create-comment: 7c0e09fb0fb238b6
  params-7: 9b079a5c2e98f4b6
  example-9: 0f2dc4a0977dd195
  edit-comment: a9d93e8208ac1550
  params-8: ab03c047450acd4a
  example-10: 2ae483709469a674
  soft-delete-comment: d622ba078ae77d97
  example-11: 7a749db61fe48bd0
  create-poll: 977c5a94bfe547b2
  params-9: d75e2afb739e464f
  example-12: edcf92d7e907da7d
  show-poll: 83b1a4d1a953d384
  example-13: 9165e5b8e0de5e9f
  list-polls: bb636cb8bc819969
  params-10: 742166bcb3fef909
  example-14: f240b608488dec44
  edit-poll: 29d16748e696444a
  params-11: 2adb993cca9ed95f
  example-15: 813370bc918d9d51
  soft-delete-poll: 1b1b7255113a6139
  example-16: 3f4003bb9e3025ec
  list-memberships: 0f6c3b751e151b2b
  params-12: 914871896bbfe70b
  example-17: e2135e6cde46f7c8
  manage-memberships: 5c06eb90945f4ad6
  params-13: 895be7fd08688cb8
  example-18: ba71317a1b5d913f
  pagination: a9da367c7c3771fd
  comments: 5407ac2a80314b49
  discussions: 9c1015a433358531
  memberships: eec7768e67133164
  polls: 6ecd728f820c96fe
  threads: 3cebe3ea615d00d3
title_source: c23fb6526b722360
title_generated: 2a1c5c279b64d7ea
---

<!-- translation-section: introduction -->

# תיעוד ה־API למשתמש של Loomio

<!-- seo-description: ניתן להשתמש ב־API למשתמש של Loomio כדי ליצור ולנהל דיונים, תגובות, סקרים, שרשורים וחברויות בקבוצות מתוך תוכנות אחרות. -->

`/api/b2` הוא ה־API המיועד למשתמשים לצורך אינטגרציות עם Loomio. הוא משתמש במפתח ה־API של חשבון משתמש, וכל פעולה מתבצעת בשם אותו חשבון.

פעולות בקבוצות משתמשות בחברויות ובהרשאות הקבוצה של החשבון שמפתח ה־API שייך לו. הרשאת ניהול של מופע Loomio אינה מרחיבה את הגישה של מפתח API לקבוצות או לתוכן; לניהול ברמת המופע יש להשתמש ב־API לשרת.

יש להשתמש במפתח ה־API של חשבון המשתמש ב־Loomio שיבצע את הפעולות. חשבון בוט ייעודי שימושי כאשר אין צורך להזמין את האינטגרציה לסקרים או לשלוח לה התראות.

לאחר כניסה לחשבון, ניתן למצוא את מפתח ה־API ואת מזהי הקבוצות ב[עמוד הגישה ל־API](/profile/api_access).

יש לשלוח את מפתח ה־API בכותרת `Authorization: Bearer`. מפתחות API במחרוזות שאילתה נדחים, מכיוון שכתובות URL עשויות להירשם בשרתי פרוקסי וביומני גישה.

```text
Authorization: Bearer YOUR_API_KEY
```

הדוגמאות משתמשות ב־`YOUR_API_KEY`, במזהה הקבוצה `123` ובכתובת `https://www.loomio.com/`. יש להחליף אותם במפתח ה־API, במזהה הקבוצה ובכתובת ההתקנה של Loomio המתאימים.

<!-- translation-section: endpoint-summary -->

## סיכום נקודות הקצה

| שיטה | נקודת קצה | מטרה |
| --- | --- | --- |
| `POST` | `/api/b2/comments` | יצירת תגובה או תשובה |
| `PATCH` | `/api/b2/comments/:id` | עריכת תגובה |
| `DELETE` | `/api/b2/comments/:id` | מחיקה רכה של תגובה |
| `POST` | `/api/b2/discussions` | יצירת דיון |
| `GET` | `/api/b2/discussions/:id` | קבלת דיון |
| `GET` | `/api/b2/discussions` | הצגת רשימת דיונים בקבוצה |
| `PATCH` | `/api/b2/discussions/:id` | עריכת דיון |
| `DELETE` | `/api/b2/discussions/:id` | מחיקה רכה של דיון |
| `GET` | `/api/b2/groups` | הצגת רשימת הקבוצות של החשבון שמפתח ה־API שייך לו |
| `GET` | `/api/b2/groups/:id_or_key_or_handle` | קבלת קבוצה שניתן לצפות בה |
| `GET` | `/api/b2/memberships` | הצגת רשימת החברויות בקבוצה |
| `POST` | `/api/b2/memberships` | הוספת חברים, ובמידת הצורך הסרת חברים שאינם ברשימה |
| `GET` | `/api/b2/reports` | הפקת דוח השתתפות |
| `POST` | `/api/b2/polls` | יצירת סקר |
| `GET` | `/api/b2/polls/:id` | קבלת סקר |
| `GET` | `/api/b2/polls` | הצגת רשימת סקרים בקבוצה |
| `PATCH` | `/api/b2/polls/:id` | עריכת סקר |
| `DELETE` | `/api/b2/polls/:id` | מחיקה רכה של סקר |
| `GET` | `/api/b2/search` | חיפוש בדיונים, בתגובות, בסקרים, בהצבעות ובמסקנות שניתן לצפות בהם |
| `GET` | `/api/b2/threads` | הצגת רשימת שרשורי דיון ושרשורי סקר עצמאיים שניתן לצפות בהם |
| `GET` | `/api/b2/threads/:topic_id` | קבלת שרשור |
| `GET` | `/api/b2/threads/:topic_id/items` | קבלת הפריטים בשרשור לפי סדרם |
| `GET` | `/api/b2/threads/:topic_id/markdown` | קבלת שרשור שלם בפורמט Markdown |
| `GET` | `/api/b2/chatbots` | הצגת רשימת אינטגרציות הצ'אט וה־webhooks של קבוצה |
| `POST` | `/api/b2/chatbots` | יצירת אינטגרציית צ'אט או webhook |
| `PATCH` | `/api/b2/chatbots/:id` | עדכון אינטגרציית צ'אט או webhook |
| `DELETE` | `/api/b2/chatbots/:id` | מחיקת אינטגרציית צ'אט או webhook |
| `POST` | `/api/b2/chatbots/check` | שליחת בדיקת חיבור ל־webhook |

<!-- translation-section: pagination -->

## חלוקה לעמודים

דיונים, קבוצות, חברויות, סקרים, שרשורים, פריטי שרשור ו־webhooks מקבלים את הפרמטרים `limit` (ברירת המחדל היא `50`) ו־`offset` (ברירת המחדל היא `0`). בקבוצות, בפריטי שרשור וב־webhooks הערך המרבי של `limit` הוא `500`.

כדי לקבל את העמוד הבא, יש להגדיל את `offset` במספר הרשומות הראשיות שהוחזרו. `meta.total` הוא המספר הכולל של הרשומות התואמות; רשומות קשורות אינן נספרות בגודל העמוד.

דוחות השתתפות מחזירים את מלוא הנתונים המבוקשים, וחיפוש מחזיר עד 20 תוצאות. שניהם אינם תומכים בחלוקה לעמודים.

דיונים, סקרים וחברויות מקבלים גם את הכינויים הישנים `per` עבור `limit` ו־`from` עבור `offset`. באינטגרציות חדשות יש להשתמש ב־`limit` וב־`offset`.

<!-- translation-section: response-size-and-related-records -->

## רשומות קשורות

תשובות ה־API למשתמש משתמשות במבנה מורכב: לצד הרשומות הראשיות נכללות רשומות קשורות, כגון נושאים, קבוצות, משתמשים, סקרים ותגובות אימוג׳י. כך יישום לקוח יכול למלא מאגר רשומות מקומי באמצעות בקשה אחת, אך התשובה עשויה לכלול יותר נתונים מהנדרש לאינטגרציה פשוטה.

יש להעביר `compact=1` כדי להשמיט רשומות קשורות עתירות נתונים של נושאים, קבוצות, קבוצות אם, חברויות, תגובות אימוג׳י, תגיות ותרגומים. הרשומות הראשיות והרשומות הקשורות הנחוצות להבנת תוכנן נשארות בתשובה.

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/threads/123/items?compact=1'
```

לשליטה ישירה, יש להעביר `exclude_types` עם סוגי רשומות בלשון יחיד, המופרדים ברווחים. לדוגמה, `exclude_types=group reaction` משמיט קבוצות ותגובות אימוג׳י קשורות. ערכים נפוצים הם `topic`, `group`, `parent`, `membership`, `reaction`, `tag`, `translation`, `user`, `discussion`, `poll`, `poll_option`, `stance`, `stance_choice`, `outcome` ו־`topic_item`. ההשמטות חלות על רשומות קשורות, ולא על המשאב הראשי המבוקש בנקודת הקצה.

תשובות של אוספים כוללות `meta.total` כאשר מוגדר גודל מדויק לאוסף. המספר הכולל מחושב לפני החלת `limit` ו־`offset`. נקודות קצה כגון חיפוש, שמחזירות במכוון מספר מוגבל של תוצאות, משמיטות את `meta.total` במקום להחזיר `null`.

<!-- translation-section: comments -->

## תגובות

<!-- translation-section: create-comment -->

### יצירת תגובה

יצירת תגובה בדיון בשם החשבון שמפתח ה־API שייך אליו.

`POST /api/b2/comments`

<!-- translation-section: params-7 -->

#### פרמטרים

| שם | תיאור |
| --- | --- |
| `discussion_id` | מספר שלם, חובה. מזהה הדיון שבו תפורסם התגובה |
| `body` | גוף התגובה, חובה אלא אם מצורף קובץ |
| `body_format` | `md` או `html`, רשות, ברירת המחדל היא `md` |

<!-- translation-section: example-9 -->

#### דוגמה

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"discussion_id": 123, "body":"example comment", "body_format":"md"}' https://www.loomio.com/api/b2/comments
```

<!-- translation-section: edit-comment -->

### עריכת תגובה

עריכת תגובה בשם החשבון שמפתח ה־API שייך אליו. חלות אותן הרשאות כמו ב־Loomio: נדרשת לחשבון הרשאה לערוך את התגובה.

`PATCH /api/b2/comments/:id`

<!-- translation-section: params-8 -->

#### פרמטרים

| שם | תיאור |
| --- | --- |
| `body` | גוף התגובה המעודכן |
| `body_format` | `md` או `html`, רשות, ברירת המחדל היא `md` |

<!-- translation-section: example-10 -->

#### דוגמה

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X PATCH -H 'Content-Type: application/json' -d '{"body":"updated comment", "body_format":"md"}' https://www.loomio.com/api/b2/comments/123
```

<!-- translation-section: soft-delete-comment -->

### מחיקה רכה של תגובה

מחיקה רכה של תגובה בשם החשבון שמפתח ה־API שייך אליו. הפעולה מסירה את התגובה, מסתירה את גוף התגובה ומשאירה את רשומת התגובה במקומה.

`DELETE /api/b2/comments/:id`

<!-- translation-section: example-11 -->

#### דוגמה

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X DELETE https://www.loomio.com/api/b2/comments/123
```

<!-- translation-section: discussions -->

## דיונים

<!-- translation-section: create-discussion -->

### יצירת דיון

יצירת דיון בשם החשבון שמפתח ה־API שייך אליו.

`POST /api/b2/discussions`

<!-- translation-section: params-3 -->

#### פרמטרים

| שם | תיאור |
| --- | --- |
| `group_id` | הקבוצה שבה יתקיים השרשור |
| `title` | כותרת השרשור, שדה חובה |
| `description` | הקשר לשרשור, שדה רשות |
| `description_format` | `md` או `html`, שדה רשות, ברירת המחדל היא `md` |
| `recipient_audience` | `group` או null. אם הערך הוא `group`, כל הקבוצה תקבל התראה על השרשור החדש |
| `recipient_user_ids` | מערך מזהי משתמשים לשליחת התראה או הזמנה לשרשור |
| `recipient_emails` | מערך כתובות דוא״ל של אנשים להזמנה לשרשור |
| `recipient_message` | הודעה שתיכלל בהזמנה בדוא״ל |

<!-- translation-section: example-2 -->

#### דוגמה

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "title":"example thread", "recipient_emails":["person@example.com"]}' https://www.loomio.com/api/b2/discussions
```

<!-- translation-section: show-discussion -->

### הצגת דיון

שליפת דיון באמצעות מזהה הדיון, שהוא מספר שלם, או מפתח, שהוא מחרוזת.

`GET /api/b2/discussions/:id`

<!-- translation-section: example-3 -->

#### דוגמה

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/discussions/abc123
```

<!-- translation-section: list-discussions -->

### רשימת דיונים

הצגת רשימת הדיונים בקבוצה הנגישים לחשבון שמפתח ה־API שייך אליו. בקבוצה הגלויה לציבור, ניתן לקבל את רשימת הדיונים הציבוריים גם ללא חברות בקבוצה; הגישה לדיונים פרטיים נשארת מוגבלת לחשבונות שיש להם הרשאה לקרוא אותם ב־Loomio.

`GET /api/b2/discussions`

<!-- translation-section: params-4 -->

#### פרמטרים

| שם | תיאור |
| --- | --- |
| `group_id` | מספר שלם, חובה. מזהה הקבוצה שממנה יש להציג את רשימת הדיונים |
| `status` | מחרוזת, רשות, ברירת המחדל היא `open`. ערכים: `open`, `closed`, `all` |
| `limit` | מספר שלם, רשות, ברירת המחדל היא 50. גודל העמוד |
| `offset` | מספר שלם, רשות, ברירת המחדל היא 0. היסט לצורך חלוקה לעמודים |

תאימות לאחור: `per` ו־`from` מתקבלים כשמות חלופיים ל־`limit` ול־`offset` וימשיכו לפעול.

<!-- translation-section: example-4 -->

#### דוגמה

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/discussions?group_id=123'
```

<!-- translation-section: edit-discussion -->

### עריכת דיון

עריכת דיון בשם החשבון שמפתח ה־API שייך אליו. חלות אותן הרשאות כמו ב־Loomio: לחשבון חייבת להיות הרשאה לערוך את הדיון הזה.

`PATCH /api/b2/discussions/:id`

<!-- translation-section: params-6 -->

#### פרמטרים

| שם | תיאור |
| --- | --- |
| `title` | כותרת מעודכנת |
| `description` | הקשר מעודכן |
| `description_format` | `md` או `html`, רשות, ברירת המחדל היא `md` |
| `recipient_audience` | `group` או null. אם הערך הוא `group`, תישלח הודעה לכל הקבוצה על העריכה |
| `recipient_user_ids` | מערך של מזהי משתמשים שיש לשלוח להם הודעה או להזמין לשרשור |
| `recipient_emails` | מערך של כתובות דוא״ל של אנשים שיש להזמין לשרשור |
| `recipient_message` | הודעה שיש לכלול בהזמנה בדוא״ל |

<!-- translation-section: example-7 -->

#### דוגמה

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X PATCH -H 'Content-Type: application/json' -d '{"title":"updated thread title", "description":"updated context", "description_format":"md"}' https://www.loomio.com/api/b2/discussions/123
```

<!-- translation-section: soft-delete-discussion -->

### מחיקה רכה של דיון

מחיקה רכה של דיון בשם החשבון שמפתח ה־API שייך אליו. הפעולה מסירה את הדיון אך משאירה את רשומת הדיון במקומה.

`DELETE /api/b2/discussions/:id`

<!-- translation-section: example-8 -->

#### דוגמה

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X DELETE https://www.loomio.com/api/b2/discussions/123
```

<!-- translation-section: groups -->

## קבוצות

<!-- translation-section: list-groups -->

<!-- translation-correction: {"before":"nt` | מספר מנהלי הקבוצה |\n| `delegates_count` | מספר הנציגים |\n| `discussions_count` | מספר הדיונ","after":"nt` | מספר מנהלי הקבוצה |\n| `discussions_count` | מספר הדיונ"} -->

### הצגת רשימת קבוצות

החזרת הקבוצות שבהן לחשבון שמפתח ה־API שייך לו יש חברות פעילה.

`GET /api/b2/groups`

| שם | תיאור |
| --- | --- |
| `limit` | מספר שלם, רשות, ברירת מחדל 50, לכל היותר 500. גודל העמוד |
| `offset` | מספר שלם, רשות, ברירת מחדל 0. היסט לחלוקה לעמודים |

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/groups?limit=50&offset=0'
```

התשובה מכילה עמוד של `groups` המסודר לפי מזהה הקבוצה בסדר עולה, עם המספר הכולל של הקבוצות המתאימות ב־`meta.total`. היא כוללת קבוצות אם ותת־קבוצות, לרבות קבוצות שהמינוי שלהן אינו פעיל כרגע. יש לבדוק את השדה `enabled` כאשר האינטגרציה אמורה לפעול רק בקבוצות מופעלות.

שדות מרכזיים של קבוצה כוללים:

| שדה | תיאור |
| --- | --- |
| `id` | מזהה קבוצה מספרי המשמש נקודות קצה אחרות של ה־API למשתמש |
| `key` | מפתח קצר וקבוע המשמש בכתובות URL של Loomio |
| `handle` | כינוי קריא של הקבוצה |
| `name` | שם הקבוצה |
| `full_name` | שם הקבוצה הכולל את ההקשר של קבוצת האם שלה |
| `parent_id` | מזהה מספרי של קבוצת האם עבור תת־קבוצה, ואחרת `null` |
| `enabled` | האם הקבוצה והמינוי שלה פעילים |
| `memberships_count` | מספר החברויות הפעילות והממתינות |
| `accepted_memberships_count` | מספר החברויות שאושרו |
| `pending_memberships_count` | מספר ההזמנות הממתינות |
| `admin_memberships_count` | מספר מנהלי הקבוצה |
| `discussions_count` | מספר הדיונים הנמצאים ישירות בקבוצה |
| `polls_count` | מספר הסקרים הנמצאים ישירות בקבוצה |
| `subgroups_count` | מספר תת־הקבוצות |

התשובה עשויה לכלול הגדרות נוספות של הקבוצה, רשומות קשורות של קבוצת האם ואת החברויות של החשבון המשתמש ב־API. על יישומי לקוח להתעלם משדות שאינם משתמשים בהם.

<!-- translation-section: get-a-group -->

### קבלת קבוצה

החזרת קבוצה אחת שהחשבון שמפתח ה־API שייך לו יכול לצפות בה.

`GET /api/b2/groups/:id_or_key_or_handle`

המזהה יכול להיות המזהה המספרי, המפתח או הכינוי של הקבוצה.

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/groups/123
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/groups/example-group
```

התשובה מכילה את הקבוצה במערך `groups` ומשתמשת באותם שדות כמו נקודת הקצה להצגת הרשימה. בקשה לקבוצה שהחשבון שמפתח ה־API שייך לו אינו יכול לגשת אליה מחזירה שגיאת הרשאה.

<!-- translation-section: memberships -->

## חברויות

<!-- translation-section: list-memberships -->

### רשימת חברויות

הצגת החברויות הגלויות לחשבון המשויך למפתח ה־API. חברי הקבוצה יכולים לקרוא את שמות החברים, המזהים, התארים והתפקידים שלהם. כתובות דוא״ל נכללות רק עבור החשבון המשויך למפתח ה־API עצמו, או כאשר לחשבון זה יש הרשאת ניהול בקבוצה.

`GET /api/b2/memberships`

<!-- translation-section: params-12 -->

#### פרמטרים

| שם | תיאור |
| --- | --- |
| `group_id` | מספר שלם, חובה. מזהה הקבוצה שהחברויות בה יוצגו ברשימה |
| `limit` | מספר שלם, רשות, ברירת מחדל 50. גודל העמוד |
| `offset` | מספר שלם, רשות, ברירת מחדל 0. היסט לחלוקה לעמודים |

תאימות לאחור: `per` ו־`from` מתקבלים כשמות חלופיים ל־`limit` ול־`offset` וימשיכו לפעול.

התשובה מכילה עמוד של `memberships` ורשומות `users` קשורות. `meta.total` הוא המספר הכולל של החברויות הגלויות בקבוצה לפני החלוקה לעמודים.

<!-- translation-section: example-17 -->

#### דוגמה

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/memberships?group_id=123&limit=50&offset=0'
```

<!-- translation-section: manage-memberships -->

### ניהול חברויות

יש לשלוח רשימה של כתובות דוא״ל. לכל הכתובות החדשות תישלח הזמנה לקבוצה. בניגוד להצגת רשימת חברויות, פעולה זו דורשת הרשאת ניהול בקבוצה.

`POST /api/b2/memberships`

<!-- translation-section: params-13 -->

#### פרמטרים

| שם | תיאור |
| --- | --- |
| `group_id` | מספר שלם, חובה. מזהה הקבוצה שהחברויות בה ינוהלו |
| `emails` | מערך של מחרוזות, חובה. כתובות דוא״ל של אנשים שיש להזמין לקבוצה |
| `remove_absent` | ערך בוליאני. אם הערך הוא true, כל מי שכתובת הדוא״ל שלהם אינה מופיעה ברשימה יוסרו מהקבוצה |

<!-- translation-section: example-18 -->

#### דוגמה

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "emails":["person@example.com"]}' https://www.loomio.com/api/b2/memberships
```

אם מועבר `remove_absent=1`, כל חברי הקבוצה שלא נכללו ברשימה יוסרו מהקבוצה. יש להיזהר: פעולה זו עלולה להסיר את כל חברי הקבוצה.

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "emails":["person@example.com"], "remove_absent": 1}' https://www.loomio.com/api/b2/memberships
```

הפעולה מחזירה אובייקט עם `{added_emails: ["person@added.com"], removed_emails: ["person@removed.com"]}`.

<!-- translation-section: participation-report -->

## דוח השתתפות

החזרת אותם נתוני השתתפות מצטברים המשמשים בדוח ההשתתפות של Loomio.

`GET /api/b2/reports`

<!-- translation-section: params-2 -->

### פרמטרים

| שם | תיאור |
| --- | --- |
| `section` | חלק בדוח: `base`, `users` או `countries`. יש להשתמש ב־`users` עבור פעילות לפי אדם |
| `group_scope` | `custom` או `my`. הערך הישן `all` מטופל כמו `my`, משום שמפתחות API למשתמש לעולם אינם מקבלים גישה לכלל המופע |
| `group_ids` | מזהי קבוצות המופרדים בפסיקים כאשר `group_scope=custom`. המערכת מתעלמת ממזהי קבוצות שהחשבון המשתמש ב־API אינו חבר בהן |
| `start_month` | החודש הראשון שיש לכלול, בפורמט `YYYY-MM`; ברירת המחדל היא לפני 12 חודשים |
| `end_month` | החודש האחרון שיש לכלול, בפורמט `YYYY-MM`; ברירת המחדל היא החודש הנוכחי |
| `interval` | מרווח הזמן בחלק `base`: `day`, `week`, `month` או `year` |
| `member_type` | יש להגדיר `delegate` יחד עם `section=users` כדי להחזיר רק נציגים מכהנים |

מעמד נציג נקבע לפי חברות פעילה בתפקיד נציג באחת מהקבוצות שנבחרו. הספירות לכל אדם מצטברות מכל הקבוצות שנבחרו. שורות הנציגים מוחזרות גם כאשר כל ספירות הפעילות הן אפס. הספירות כוללות שרשורים, תגובות, סקרים, הצבעות, מסקנות ותגובות אימוג׳י; הן אינן שיעורי השתתפות בהצבעה. שורות המשתמשים כוללות גם מספרי פתקי הצבעה מזוהים שהונפקו, שמולאו ושלא מולאו. סקרים אנונימיים אינם נכללים באף אחת מספירות ההצבעה לפי אדם. הערך של `all_votes_cast` הוא true רק כאשר הונפק לפחות פתק הצבעה אחד וכל פתקי ההצבעה שהונפקו מולאו.

ה־API מחיל את אותם כללי נראות הקבוצות כמו הדוח בממשק המוצר. מפתח API למשתמש אינו יכול לחשוף נתוני דוח מקבוצות שאין לחשבון גישה אליהן.

<!-- translation-section: example -->

### דוגמה

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/reports?section=users&group_scope=custom&group_ids=123&member_type=delegate&start_month=2026-01&end_month=2026-09'
```

המערך `users` מכיל שורות פעילות מלאות:

```json
{
  "users": [
    {
      "id": 456,
      "name": "Ada Lovelace",
      "country": "NZ",
      "delegate": true,
      "threads": 2,
      "comments": 8,
      "polls": 1,
      "votes": 5,
      "votes_cast": 5,
      "votes_issued": 6,
      "votes_missed": 1,
      "all_votes_cast": false,
      "outcomes": 1,
      "reactions": 4
    }
  ]
}
```

<!-- translation-section: polls -->

## סקרים

<!-- translation-section: create-poll -->

### יצירת סקר

יצירת סקר בשם החשבון שמפתח ה־API שייך לו.

`POST /api/b2/polls`

<!-- translation-section: params-9 -->

#### פרמטרים

| שם | תיאור |
| --- | --- |
| `group_id` | מספר שלם, לא חובה, ברירת המחדל היא null. מזהה הקבוצה של הסקר. אם מועבר `discussion_id`, המערכת מתעלמת מ־`group_id` |
| `discussion_id` | מספר שלם, לא חובה, ברירת המחדל היא null. מזהה שרשור הדיון שאליו יש להוסיף את הסקר |
| `title` | מחרוזת, חובה. כותרת הסקר |
| `poll_type` | מחרוזת, חובה. ערכים: `proposal`, `poll`, `count`, `score`, `ranked_choice`, `meeting`, `dot_vote` |
| `details` | מחרוזת, לא חובה. טקסט גוף הסקר |
| `details_format` | מחרוזת, לא חובה, ברירת המחדל היא `md`. ערכים: `md` או `html` |
| `options` | מערך מחרוזות. אם `poll_type` הוא `proposal`, הערכים התקפים הם `agree`, `disagree`, `abstain`, `block`. אם `poll_type` הוא `meeting`, יש לספק מחרוזות תאריך או תאריך ושעה בפורמט ISO 8601. בכל סוגי הסקרים האחרים, כל מחרוזת תקפה |
| `closing_at` | מחרוזת בפורמט ISO 8601 או null, ברירת המחדל היא null. דוגמה: `2026-09-01T12:00:00Z`. אם הערך הוא null, ההצבעה מושבתת והסקר נחשב לסקר בהכנה |
| `specified_voters_only` | ערך בוליאני, לא חובה, ברירת המחדל היא false. אם הערך הוא true, רק אנשים שצוינו יכולים להצביע. אם הערך הוא false, כל חברי הקבוצה יקבלו הזמנה להצביע |
| `hide_results` | מחרוזת, לא חובה, ברירת המחדל היא `off`. ערכים: `off`, `until_vote`, `until_closed` |
| `shuffle_options` | ערך בוליאני, ברירת המחדל היא false. הצגת האפשרויות למצביעים בסדר אקראי |
| `anonymous` | ערך בוליאני, לא חובה, ברירת המחדל היא false. הסתרת זהויות המצביעים |
| `recipient_audience` | `group` או null, לא חובה, ברירת המחדל היא null. אם הערך הוא `group`, כל הקבוצה תקבל התראה |
| `notify_on_closing_soon` | מחרוזת, לא חובה, ברירת המחדל היא `nobody`. ערכים: `nobody`, `author`, `undecided_voters`, `voters` |
| `recipient_user_ids` | מערך מזהי משתמשים לשליחת התראה או הזמנה |
| `recipient_emails` | מערך כתובות דוא״ל של אנשים שיקבלו הזמנה להצביע |
| `recipient_message` | הודעה שתיכלל בהזמנה בדוא״ל |
| `notify_recipients` | ערך בוליאני, ברירת המחדל היא false. אם הערך הוא false, אנשים מתווספים ללא שליחת התראות. אם הערך הוא true, כל מי שקיבלו הזמנה בבקשה זו יקבלו התראה בדוא״ל |

<!-- translation-section: example-12 -->

#### דוגמה

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "title":"example poll", "poll_type": "proposal", "options": ["agree", "disagree"], "closing_at": "2026-09-01T12:00:00Z", "recipient_emails":["person@example.com"]}' https://www.loomio.com/api/b2/polls
```

<!-- translation-section: show-poll -->

### הצגת סקר

אחזור סקר באמצעות מזהה הסקר, שהוא מספר שלם, או מפתח, שהוא מחרוזת.

`GET /api/b2/polls/:id`

<!-- translation-section: example-13 -->

#### דוגמה

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/polls/abc123
```

<!-- translation-section: list-polls -->

### רשימת סקרים

הצגת רשימת הסקרים בקבוצה הגלויים לחשבון שמפתח ה־API שייך לו. בקבוצה הגלויה לציבור, ניתן לקבל את רשימת הסקרים הציבוריים גם ללא חברות בקבוצה; הגישה לסקרים פרטיים נשארת מוגבלת למשתמשים שיש להם הרשאה לקרוא אותם ב־Loomio. התשובה כוללת את המסקנה הנוכחית של כל סקר גלוי, כך שניתן להשתמש ב־`status=closed` לקבלת רשימת הצעות שהתקבלה לגביהן החלטה.

`GET /api/b2/polls`

<!-- translation-section: params-10 -->

#### פרמטרים

| שם | תיאור |
| --- | --- |
| `group_id` | מספר שלם, חובה. מזהה הקבוצה שממנה יש להציג את רשימת הסקרים |
| `status` | מחרוזת, לא חובה, ברירת המחדל היא `active`. ערכים: `active`, `closed`, `all` |
| `limit` | מספר שלם, לא חובה, ברירת המחדל היא 50. גודל העמוד |
| `offset` | מספר שלם, לא חובה, ברירת המחדל היא 0. היסט לחלוקה לעמודים |

תאימות לאחור: `per` ו־`from` מתקבלים כשמות חלופיים ל־`limit` ול־`offset` וימשיכו לפעול.

<!-- translation-section: example-14 -->

#### דוגמה

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/polls?group_id=123'
```

<!-- translation-section: edit-poll -->

### עריכת סקר

עריכת סקר בשם החשבון שמפתח ה־API שייך לו. חלות אותן הרשאות כמו ב־Loomio: לחשבון חייבת להיות הרשאה לערוך את הסקר.

`PATCH /api/b2/polls/:id`

<!-- translation-section: params-11 -->

#### פרמטרים

| שם | תיאור |
| --- | --- |
| `title` | כותרת מעודכנת |
| `details` | פרטי הסקר המעודכנים |
| `details_format` | `md` או `html`, לא חובה, ברירת המחדל היא `md` |
| `options` | שמות האפשרויות המעודכנים. שינוי האפשרויות עשוי להשפיע על הצבעות קיימות, בהתאם למצב הסקר |
| `closing_at` | מחרוזת בפורמט ISO 8601 או null |
| `recipient_audience` | `group` או null. אם הערך הוא `group`, כל הקבוצה תקבל התראה |
| `recipient_user_ids` | מערך מזהי משתמשים לשליחת התראה או הזמנה |
| `recipient_emails` | מערך כתובות דוא״ל של אנשים שיקבלו הזמנה להצביע |
| `recipient_message` | הודעה שתיכלל בהזמנה בדוא״ל |

<!-- translation-section: example-15 -->

#### דוגמה

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X PATCH -H 'Content-Type: application/json' -d '{"title":"updated poll title", "details":"updated details", "details_format":"md"}' https://www.loomio.com/api/b2/polls/123
```

<!-- translation-section: soft-delete-poll -->

### מחיקה רכה של סקר

מחיקה רכה של סקר בשם החשבון שמפתח ה־API שייך לו. פעולה זו מסמנת את הסקר כמחוק ומשאירה את רשומת הסקר במקומה.

`DELETE /api/b2/polls/:id`

<!-- translation-section: example-16 -->

#### דוגמה

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X DELETE https://www.loomio.com/api/b2/polls/123
```

<!-- translation-section: search -->

## חיפוש

חיפוש דיונים, תגובות, סקרים, הצבעות ומסקנות הגלויים לחשבון שמפתח ה־API שייך אליו. התוצאות כוללות תוכן ציבורי גם ללא חברות בקבוצה שלו; תוכן פרטי עדיין כפוף לכללי הנראות הרגילים של השרשור.

`GET /api/b2/search`

<!-- translation-section: params -->

### פרמטרים

| שם | תיאור |
| --- | --- |
| `query` | טקסט לחיפוש. נתמכות התאמות מדויקות ומקורבות |
| `group_id` | הגבלת התוצאות לקבוצה גלויה אחת |
| `org_id` | הגבלת התוצאות לקבוצת אם גלויה ולתת־הקבוצות הגלויות שלה. יש להשתמש ב־`0` עבור דיונים ישירים |
| `type` | הגבלת התוצאות לסוג אחד: `Discussion`, `Comment`, `Poll`, `Stance` או `Outcome` |
| `types` | רשימת סוגי תוצאות המופרדים בפסיקים |
| `tag` | הגבלת התוצאות לשרשורים עם תגית זו |
| `author_id` | הגבלת התוצאות לתוכן שנכתב בחשבון אחד. ללא `query`, מוחזרת הפעילות הגלויה האחרונה של אותו חשבון |
| `order` | יש להגדיר `authored_at_desc` כדי למיין את התוכן התואם לפי מועד הכתיבה |

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/search?query=quarterly+planning&type=Discussion'
```

התשובה מכילה מערך `search_results`. כל תוצאה מזהה את הרשומה התואמת ואת ההקשר הגלוי שלה באמצעות שדות הכוללים את `searchable_type`, `searchable_id`, `highlight`, `group_id`, `group_name`, `discussion_key`, `poll_key`, `author_id`, `author_name`, `authored_at` ו־`tags`. שדות שאינם רלוונטיים לתוצאה מקבלים את הערך `null`.

<!-- translation-section: threads -->

## שרשורים

<!-- translation-section: list-threads -->

### רשימת שרשורים

הצגת רשימת שרשורי הדיון והסקר הנגישים לחשבון שמפתח ה-API שייך אליו, לפי סדר הפעילות האחרונה. מזהה השרשור הוא ה-`topic_id` שלו.

`GET /api/b2/threads`

<!-- translation-section: params-5 -->

#### פרמטרים

| שם | תיאור |
| --- | --- |
| `limit` | מספר שלם, רשות, ברירת המחדל היא 50. גודל העמוד |
| `offset` | מספר שלם, רשות, ברירת המחדל היא 0. היסט לצורך חלוקה לעמודים |

<!-- translation-section: example-5 -->

#### דוגמה

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/threads?limit=50&offset=0'
```

<!-- translation-section: read-thread -->

### קריאת שרשור

קריאת שרשור, רצף האירועים המסודר שלו, או מסמך ה-Markdown המלא של התוכן הנגיש בו.

`GET /api/b2/threads/:topic_id`

`GET /api/b2/threads/:topic_id/items`

`GET /api/b2/threads/:topic_id/markdown`

נקודת הקצה `items` מקבלת את הפרמטרים הבאים לחלוקה לעמודים:

| שם | תיאור |
| --- | --- |
| `limit` | מספר שלם, רשות, ברירת המחדל היא 50, הערך המרבי הוא 500. גודל העמוד |
| `offset` | מספר שלם, רשות, ברירת המחדל היא 0. היסט לצורך חלוקה לעמודים |

<!-- translation-section: example-6 -->

#### דוגמה

```text
GET https://www.loomio.com/api/b2/threads/<topic_id>
GET https://www.loomio.com/api/b2/threads/<topic_id>/items?limit=50&offset=0
GET https://www.loomio.com/api/b2/threads/<topic_id>/markdown
```

נקודת הקצה `items` מחזירה עמוד מתוך רצף האירועים בסדר עולה, כולל תגובות, סקרים, הצבעות ומסקנות הנגישים לחשבון. `meta.total` הוא המספר הכולל של הפריטים בשרשור. כדי לקרוא את הרצף כולו, יש לאחזר את העמודים הבאים. נקודת הקצה `markdown` מחזירה את כל התוכן הנגיש בשרשור כמסמך Markdown אחד. נימוקי ההצבעות נכללים רק כאשר הם נגישים לחשבון שמפתח ה-API שייך אליו.

כל נקודות הקצה של השרשורים אוכפות את אותן הרשאות כמו ממשק Loomio. מפתח ה-API אינו מעניק גישה לשרשור שאין לחשבון הרשאה לפתוח בדרך הרגילה.

<!-- translation-section: webhooks -->

## Webhooks

ה־API למשתמש מבוסס על בקשות: אינטגרציה פונה ל־Loomio כשנדרש לקרוא או לשנות נתונים. webhook של קבוצה מאפשר שליחת נתונים בכיוון ההפוך. Loomio שולחת אירועים נבחרים של הקבוצה לנקודת הקצה שהוגדרה בזמן התרחשותם, כך שאין צורך שהאינטגרציה תבדוק שוב ושוב את ה־REST API כדי לזהות שינויים.

Webhooks מוגדרים לכל קבוצה בנפרד ודורשים הרשאת ניהול של הקבוצה. ניתן לנהל אותם דרך הממשק של Loomio:

1. יש לפתוח את הקבוצה.
2. יש לפתוח את תפריט הקבוצה ולבחור **אינטגרציות צ'אט**.
3. יש להוסיף את האינטגרציה המתאימה לפורמט הנתונים שנקודת הקצה מקבלת. לנקודת קצה לשימוש כללי, יש להשתמש בפורמט Mattermost/Markdown.
4. יש להזין שם ואת כתובת ה־URL של היעד.
5. יש לבחור את האירועים ש־Loomio תשלח אוטומטית.
6. יש לשמור את האינטגרציה ולהשתמש ב־**בדיקת חיבור** כדי לשלוח הודעת בדיקה.

יש להשתמש ביעד HTTPS עם כתובת URL שלא ניתן לנחש. Loomio דורשת שכתובת היעד תיפתר לכתובת ציבורית, וחוסמת בקשות לכתובות מקומיות או לכתובות ברשתות פרטיות.

סוכנים ואינטגרציות אחרות יכולים לנהל webhooks גם דרך נקודות הקצה של chatbots המתוארות בהמשך, באמצעות אימות Bearer. המשאב נקרא `chatbots` לצורך תאימות לאינטגרציות הצ'אט של Loomio, אך הוא מייצג גם webhooks יוצאים לשימוש כללי.

<!-- translation-section: list-webhooks -->

### הצגת רשימת webhooks

החזרת אינטגרציות הצ'אט המוגדרות לקבוצה. לחשבון שמפתח ה־API שייך לו חייבת להיות הרשאת ניהול של הקבוצה. התשובה כוללת כתובות URL של יעדים, ולכן אין לחשוף אותה לחברי קבוצה רגילים.

`GET /api/b2/chatbots?group_id=123`

| שם | תיאור |
| --- | --- |
| `group_id` | מספר שלם, חובה. מזהה הקבוצה שאת ה־webhooks שלה יש להציג ברשימה |
| `limit` | מספר שלם, רשות, ברירת המחדל היא 50, הערך המרבי הוא 500. גודל העמוד |
| `offset` | מספר שלם, רשות, ברירת המחדל היא 0. היסט לצורך חלוקה לעמודים |

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/chatbots?group_id=123&limit=50&offset=0'
```

התשובה מכילה עמוד של `chatbots` המסודר לפי מזהה האינטגרציה בסדר עולה, וב־`meta.total` מופיע המספר הכולל של האינטגרציות בקבוצה. לכל אינטגרציה יש השדות הבאים:

| שדה | תיאור |
| --- | --- |
| `id` | מזהה האינטגרציה המשמש לעדכון ולמחיקה |
| `group_id` | הקבוצה המקבלת את האירועים |
| `name` | שם האינטגרציה לצורכי ניהול |
| `kind` | `webhook` עבור webhook יוצא או `matrix` עבור אינטגרציית Matrix |
| `webhook_kind` | פורמט הנתונים: `markdown`, `slack`, `discord`, `microsoft` או `webex` |
| `server` | כתובת ה־URL של היעד |
| `event_kinds` | אירועים הנשלחים אוטומטית |
| `notification_only` | האם ההודעות מכילות רק את כותרת ההתראה |

<!-- translation-section: create-a-webhook -->

### יצירת webhook

`POST /api/b2/chatbots`

```bash
curl -X POST \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{
    "group_id": 123,
    "name": "Planning system",
    "kind": "webhook",
    "webhook_kind": "markdown",
    "server": "https://hooks.example.org/loomio/unguessable-token",
    "event_kinds": ["new_discussion", "new_comment", "poll_created", "outcome_created"],
    "notification_only": false
  }' \
  https://www.loomio.com/api/b2/chatbots
```

לחשבון שמפתח ה־API שייך לו חייבת להיות הרשאת ניהול של הקבוצה המזוהה באמצעות `group_id`. לפני השמירה נבדק שכתובת היעד היא כתובת URL ציבורית.

<!-- translation-section: update-a-webhook -->

### עדכון webhook

`PATCH /api/b2/chatbots/:id`

יש לשלוח את השדות שיש לשנות. לא ניתן להעביר את ה־webhook לקבוצה אחרת באמצעות שינוי `group_id`.

```bash
curl -X PATCH \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"name":"Planning events","event_kinds":["new_discussion","outcome_created"]}' \
  https://www.loomio.com/api/b2/chatbots/456
```

<!-- translation-section: test-a-webhook-destination -->

### בדיקת יעד של webhook

שליחת הודעת בדיקה התואמת ל־Markdown ליעד, לפני שמירת ההגדרות שלו או אחריה.

`POST /api/b2/chatbots/check`

```bash
curl -X POST \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"group_id":123,"server":"https://hooks.example.org/loomio/unguessable-token"}' \
  https://www.loomio.com/api/b2/chatbots/check
```

<!-- translation-section: delete-a-webhook -->

### מחיקת webhook

`DELETE /api/b2/chatbots/:id`

```bash
curl -X DELETE -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/chatbots/456
```

מחיקת ההגדרות מפסיקה שליחות עתידיות. היא אינה מוחקת תוכן כלשהו מקבוצת Loomio.

<!-- translation-section: event-types -->

### סוגי אירועים

ניתן להגדיר webhook לקבלת סוגי האירועים הבאים:

| אירוע | מתי הוא נשלח |
| --- | --- |
| `new_discussion` | נפתח דיון |
| `discussion_edited` | דיון נערך |
| `new_comment` | נוצרת תגובה |
| `poll_created` | נפתח סקר |
| `poll_edited` | סקר נערך |
| `poll_closing_soon` | סקר מתקרב למועד הסגירה שלו |
| `poll_expired` | סקר מגיע למועד הסגירה שלו |
| `poll_closed_by_user` | סקר נסגר ידנית |
| `poll_reopened` | סקר נפתח מחדש |
| `outcome_created` | מתפרסמת מסקנה |
| `outcome_updated` | מסקנה מתעדכנת |
| `outcome_review_due` | מגיע המועד לבחינה מחדש של מסקנה |
| `stance_created` | מתבצעת הצבעה |
| `stance_updated` | הצבעה משתנה |

ה־webhook שייך לקבוצה אחת ומקבל ממנה את האירועים שנבחרו. ניתן גם לבחור במפורש באינטגרציה בעת שיתוף או שליחת התראות מסוימות, גם אם האירוע האוטומטי המתאים לא נבחר.

<!-- translation-section: http-delivery -->

### שליחה באמצעות HTTP

Loomio שולח בקשת HTTP `POST` באופן אסינכרוני לכתובת שהוגדרה, עם הכותרת הבאה:

```text
Content-Type: application/json; charset=utf-8
```

זמן ההמתנה המרבי לבקשה הוא חמש שניות. תשובת `2xx`, לרבות `204 No Content`, נחשבת להצלחה. שירותים המקבלים הודעות webhook צריכים להשיב במהירות, לבצע עיבוד ממושך באופן אסינכרוני, ולתמוך בקבלת הודעות כפולות או הודעות המגיעות שלא לפי הסדר.

Loomio אינו מוסיף כרגע חתימת webhook, כותרת עם סוד משותף, מזהה אירוע או מזהה שליחה. יש להתייחס לכתובת היעד המלאה כאל פרט אימות, להימנע מחשיפתה לציבור ולכלול בכתובת אסימון שלא ניתן לנחש כאשר השירות המקבל תומך בכך. אם נדרשת סכמת אירועים יציבה הניתנת לקריאה ממוחשבת או שליחה חתומה, יש להשתמש ב־webhook כהתראה על שינוי ולאחזר את הרשומות העדכניות דרך ה־API למשתמש עם אימות.

<!-- translation-section: payload-formats -->

### פורמטים של מטעני נתונים

מטעני הנתונים של Webhook הם הודעות המיועדות להצגה בשירותי צ'אט. הם אינם רשומות Loomio מלאות שעברו סריאליזציה. הקישורים בהודעה מזהים את התוכן הרלוונטי ב-Loomio; כאשר נדרש מידע מובנה על המצב הנוכחי, ניתן לשלוף אותו באמצעות ה-API למשתמש.

| פורמט האינטגרציה | שדות JSON עיקריים |
| --- | --- |
| Mattermost/Markdown | `text`, `icon_url`, `username` |
| Slack | `text` |
| Discord | `content`, מוגבל לכ-1,900 תווים |
| Microsoft Teams | `@type`, `@context`, `themeColor`, `text`, `sections` |
| Webex | `markdown` |

לדוגמה, פורמט Markdown הכללי שולח גוף הודעה במבנה הבא:

```json
{
  "text": "Ada started a discussion: [Quarterly planning](https://example.loomio.org/d/example)",
  "icon_url": "https://example.loomio.org/path/to/group-logo.png",
  "username": "Loomio"
}
```

הנוסח המדויק של ההודעה תלוי באירוע, בהגדרות השפה והאזור של הקבוצה, בהגדרה לשליחת כותרת ההתראה בלבד ובגרסת Loomio. בעת עיבוד ההודעות יש להסתמך על השדות המתועדים ברמה העליונה של הפורמט שנבחר, במקום לנתח את ניסוח המשפטים.
