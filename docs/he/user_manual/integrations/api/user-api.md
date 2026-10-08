---
title: API למשתמש
source_revision: f214d1d252cc5b1f895c3319fa8f65132f1a287a
source_file: docs/en/user_manual/integrations/api/user-api.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-09'
sections:
  introduction: a43c8b800d13fd33
  authentication-change: 06b5c2cd9d9e72a0
  response-size-and-related-records: 1ffc59ad606a87e7
  endpoint-summary: 52c480c59d3669e3
  groups: 0473f1f7fb78f074
  list-groups: dcbe9217091f8cb2
  get-a-group: dffef659cb92745e
  webhooks: f65fa289f8c1b808
  list-webhooks: a8b52c1a9bfdb16c
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
  create-discussion: ad202a0bdbfa7c2e
  params-3: 529f10e32be74c5c
  example-2: f25daafbba33718c
  show-discussion: b61aea6bf3d55e16
  example-3: e095e8e34cd562a0
  list-discussions: f209b8feb7c795a6
  params-4: 3ec197245f595be6
  example-4: 37d59c03fee8a15b
  list-threads: 34edc6c34552e136
  params-5: a5f41285afccdc8b
  example-5: 81c145ad5f6eb232
  read-thread: 0de1409aaa00b9ac
  example-6: 7c7553e1a3e94070
  edit-discussion: 1ab04653354b8036
  params-6: 4d3f5862a5f948b4
  example-7: d2a61a34af9e99c3
  soft-delete-discussion: fdb0d4db8470524c
  example-8: 423894a70b5ce489
  create-comment: bf95ee58b610f2fd
  params-7: 7af2127e1f721b66
  example-9: 4e7d49ac39938c12
  edit-comment: 49e722ec6bca25a1
  params-8: b2be783e4398d866
  example-10: bf626a7f693182c3
  soft-delete-comment: afb51bf4074aeab7
  example-11: e39b758ad0d7aa62
  create-poll: b2a11ae34ce22151
  params-9: 3e592c12f9cbb757
  example-12: f5d6029049637276
  show-poll: 2e7a14ac23eeffa6
  example-13: 1a5acf0b8a6f62f2
  list-polls: 606f27566d6d5f98
  params-10: 1b1a6f003f91eb9a
  example-14: 710a82f6b2203f48
  edit-poll: 42b85770aebd8ef2
  params-11: 52d278a2f38d6a9f
  example-15: 8f7d523fc36f5da7
  soft-delete-poll: 0f1b24e1263dcfbe
  example-16: ec71cfcd4a0b98ab
  list-memberships: 82712683aa3a424a
  params-12: d2fc821e97d53145
  example-17: 266443e0eb35078c
  manage-memberships: 3c821029101515ad
  params-13: 249b307203206387
  example-18: ffd950cd7ab5aaec
generated:
  introduction: 63c62a412472f11b
  authentication-change: c9947193f95b1d9f
  response-size-and-related-records: e061a3e9b2df8303
  endpoint-summary: 7c1b34478c62b9fd
  groups: 05c42ae402e79755
  list-groups: e1c5dddb03a20542
  get-a-group: 8bd2ae664cbaaa38
  webhooks: 14d9495f3dd01876
  list-webhooks: 860c6cde71d273e9
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
  create-discussion: b27b2da7ba33594f
  params-3: 976b0153d9d9e7a4
  example-2: a9e2934fac9fe85b
  show-discussion: 1874a33e910ff43e
  example-3: 9b68959346737a9f
  list-discussions: 510aa69fae8b9f33
  params-4: fbb9f52cf0d962de
  example-4: 2ab92caa61cc2c64
  list-threads: b0cac164db186bda
  params-5: 9779028fe8703e9d
  example-5: c000286719036d3d
  read-thread: 7eddb0044a9c410a
  example-6: e016cc1c675a10a0
  edit-discussion: 49663ab3bff3ec0d
  params-6: 33af92f1a6d9ea74
  example-7: 1452f7cf1715031d
  soft-delete-discussion: bd61f0aa62a69e29
  example-8: 87b40795a210d4d4
  create-comment: c8256c64b9251b3d
  params-7: 73525752f2e43249
  example-9: c6989ae0568989cb
  edit-comment: fe39216f0a9e7832
  params-8: a6fdfaa616380542
  example-10: d1825db5ab1b9e8a
  soft-delete-comment: f378c068b5a52e91
  example-11: 045335d89a7fb779
  create-poll: 8dcc29269a9b4db6
  params-9: 50728ef2987130af
  example-12: 218c20faadfec3c8
  show-poll: 07e015bd74e24979
  example-13: e271e6a44e58378f
  list-polls: 88b5eae4b2bf31b0
  params-10: c981ccd8c4c60a34
  example-14: e1b869ce21cfc46b
  edit-poll: b6f5af0887a074b6
  params-11: c5f343e84930d2ba
  example-15: f9539a1c7e692b04
  soft-delete-poll: f98c8b17d1d123ea
  example-16: 06de09d9a51dfb6e
  list-memberships: e7e5a9d3316d1923
  params-12: 77b5be776ec822ba
  example-17: 125d4adb5493a71d
  manage-memberships: ca4f3ba938ece598
  params-13: cdeffdf8b21220c7
  example-18: 9d67fe3f049f5ccd
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

<!-- translation-section: authentication-change -->

### שינוי באימות

בעבר ניתן היה להעביר את מפתח ה־API כפרמטר `api_key` בכתובת URL. בקשות המשתמשות ב־`?api_key=YOUR_API_KEY` אינן פועלות עוד. יש להשתמש במקום זאת בכותרת HTTP בשם `Authorization`:

```text
Authorization: Bearer YOUR_API_KEY
```

הדוגמאות משתמשות ב־`YOUR_API_KEY`, במזהה הקבוצה `123` ובכתובת `https://www.loomio.com/`. יש להחליף אותם במפתח ה־API, במזהה הקבוצה ובכתובת התקנת Loomio המתאימים.

<!-- translation-section: response-size-and-related-records -->

## גודל התשובה ורשומות קשורות

תשובות ה־API למשתמש משתמשות במבנה מורכב: לצד הרשומות הראשיות נכללות רשומות קשורות, כגון נושאים, קבוצות, משתמשים, סקרים ותגובות אימוג׳י. כך יישום לקוח יכול למלא מאגר רשומות מקומי באמצעות בקשה אחת, אך התשובה עשויה לכלול יותר נתונים מהנדרש לאינטגרציה פשוטה.

יש להעביר `compact=1` כדי להשמיט רשומות קשורות עתירות נתונים של נושאים, קבוצות, קבוצות אם, חברויות, תגובות אימוג׳י, תגיות ותרגומים. הרשומות הראשיות והרשומות הקשורות הנחוצות להבנת תוכנן נשארות בתשובה.

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/threads/123/items?compact=1'
```

לשליטה ישירה, יש להעביר `exclude_types` עם סוגי רשומות בלשון יחיד, המופרדים ברווחים. לדוגמה, `exclude_types=group reaction` משמיט קבוצות ותגובות אימוג׳י קשורות. ערכים נפוצים הם `topic`, `group`, `parent`, `membership`, `reaction`, `tag`, `translation`, `user`, `discussion`, `poll`, `poll_option`, `stance`, `stance_choice`, `outcome` ו־`topic_item`. ההשמטות חלות על רשומות קשורות, ולא על המשאב הראשי המבוקש בנקודת הקצה.

תשובות של אוספים כוללות `meta.total` כאשר מוגדר גודל מדויק לאוסף. המספר הכולל מחושב לפני החלת `limit` ו־`offset`. נקודות קצה כגון חיפוש, שמחזירות במכוון מספר מוגבל של תוצאות, משמיטות את `meta.total` במקום להחזיר `null`.

<!-- translation-section: endpoint-summary -->

## סיכום נקודות הקצה

| שיטה | נקודת קצה | מטרה |
| --- | --- | --- |
| `GET` | `/api/b2/groups` | הצגת רשימת הקבוצות של החשבון שמפתח ה־API שייך לו |
| `GET` | `/api/b2/groups/:id_or_key_or_handle` | קבלת קבוצה שניתן לצפות בה |
| `GET` | `/api/b2/reports` | הפקת דוח השתתפות |
| `GET` | `/api/b2/search` | חיפוש בדיונים, בתגובות, בסקרים, בהצבעות ובמסקנות שניתן לצפות בהם |
| `POST` | `/api/b2/discussions` | יצירת דיון |
| `GET` | `/api/b2/discussions/:id` | קבלת דיון |
| `GET` | `/api/b2/discussions` | הצגת רשימת דיונים בקבוצה |
| `PATCH` | `/api/b2/discussions/:id` | עריכת דיון |
| `DELETE` | `/api/b2/discussions/:id` | מחיקה רכה של דיון |
| `GET` | `/api/b2/threads` | הצגת רשימת שרשורי דיון ושרשורי סקר עצמאיים שניתן לצפות בהם |
| `GET` | `/api/b2/threads/:topic_id` | קבלת שרשור |
| `GET` | `/api/b2/threads/:topic_id/items` | קבלת הפריטים בשרשור לפי סדרם |
| `GET` | `/api/b2/threads/:topic_id/markdown` | קבלת שרשור שלם בפורמט Markdown |
| `POST` | `/api/b2/comments` | יצירת תגובה או תשובה |
| `PATCH` | `/api/b2/comments/:id` | עריכת תגובה |
| `DELETE` | `/api/b2/comments/:id` | מחיקה רכה של תגובה |
| `POST` | `/api/b2/polls` | יצירת סקר |
| `GET` | `/api/b2/polls/:id` | קבלת סקר |
| `GET` | `/api/b2/polls` | הצגת רשימת סקרים בקבוצה |
| `PATCH` | `/api/b2/polls/:id` | עריכת סקר |
| `DELETE` | `/api/b2/polls/:id` | מחיקה רכה של סקר |
| `GET` | `/api/b2/memberships` | הצגת רשימת החברויות בקבוצה |
| `POST` | `/api/b2/memberships` | הוספת חברים, ובמידת הצורך הסרת חברים שאינם ברשימה |
| `GET` | `/api/b2/chatbots` | הצגת רשימת אינטגרציות הצ'אט וה־webhooks של קבוצה |
| `POST` | `/api/b2/chatbots` | יצירת אינטגרציית צ'אט או webhook |
| `PATCH` | `/api/b2/chatbots/:id` | עדכון אינטגרציית צ'אט או webhook |
| `DELETE` | `/api/b2/chatbots/:id` | מחיקת אינטגרציית צ'אט או webhook |
| `POST` | `/api/b2/chatbots/check` | שליחת בדיקת חיבור ל־webhook |

<!-- translation-section: groups -->

## קבוצות

<!-- translation-section: list-groups -->

<!-- translation-correction: {"before":"nt` | מספר מנהלי הקבוצה |\n| `delegates_count` | מספר הנציגים |\n| `discussions_count` | מספר הדיונ","after":"nt` | מספר מנהלי הקבוצה |\n| `discussions_count` | מספר הדיונ"} -->

### הצגת רשימת קבוצות

החזרת הקבוצות שבהן לחשבון שמפתח ה־API שייך לו יש חברות פעילה.

`GET /api/b2/groups`

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/groups
```

התשובה מכילה את כל הרשומות המתאימות במערך `groups` ללא חלוקה לעמודים. היא כוללת קבוצות אם ותת־קבוצות, לרבות קבוצות שהמינוי שלהן אינו פעיל כרגע. יש לבדוק את השדה `enabled` כאשר האינטגרציה אמורה לפעול רק בקבוצות מופעלות.

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

התשובה עשויה לכלול הגדרות נוספות של הקבוצה, רשומות קשורות של קבוצת האם ואת החברויות של החשבון המשתמש ב־API. יישומי לקוח צריכים להתעלם משדות שאינם משתמשים בהם.

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

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/chatbots?group_id=123'
```

התשובה מכילה מערך `chatbots` עם השדות הבאים:

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

<!-- translation-section: create-discussion -->

## יצירת דיון

יצירת דיון בשם החשבון שמפתח ה־API שייך אליו.

`POST /api/b2/discussions`

<!-- translation-section: params-3 -->

### פרמטרים

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

### דוגמה

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "title":"example thread", "recipient_emails":["person@example.com"]}' https://www.loomio.com/api/b2/discussions
```

<!-- translation-section: show-discussion -->

## הצגת דיון

שליפת דיון באמצעות מזהה הדיון, שהוא מספר שלם, או מפתח, שהוא מחרוזת.

`GET /api/b2/discussions/:id`

<!-- translation-section: example-3 -->

### דוגמה

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/discussions/abc123
```

<!-- translation-section: list-discussions -->

## רשימת דיונים

הצגת רשימת הדיונים בקבוצה הנגישים לחשבון שמפתח ה-API שייך אליו. בקבוצה הגלויה לציבור, ניתן לקבל את רשימת הדיונים הציבוריים גם ללא חברות בקבוצה; הגישה לדיונים פרטיים נשארת מוגבלת לחשבונות שיש להם הרשאה לקרוא אותם ב-Loomio.

`GET /api/b2/discussions`

<!-- translation-section: params-4 -->

### פרמטרים

| שם | תיאור |
| --- | --- |
| `group_id` | מספר שלם, חובה. מזהה הקבוצה שממנה יש להציג את רשימת הדיונים |
| `status` | מחרוזת, רשות, ברירת המחדל היא `open`. ערכים: `open`, `closed`, `all` |
| `limit` | מספר שלם, רשות, ברירת המחדל היא 50. גודל העמוד |
| `offset` | מספר שלם, רשות, ברירת המחדל היא 0. היסט לצורך חלוקה לעמודים |

תאימות לאחור: `per` ו-`from` מתקבלים כשמות חלופיים ל-`limit` ול-`offset` וימשיכו לפעול.

<!-- translation-section: example-4 -->

### דוגמה

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/discussions?group_id=123'
```

<!-- translation-section: list-threads -->

## רשימת שרשורים

הצגת רשימת שרשורי הדיון והסקר הנגישים לחשבון שמפתח ה-API שייך אליו, לפי סדר הפעילות האחרונה. מזהה השרשור הוא ה-`topic_id` שלו.

`GET /api/b2/threads`

<!-- translation-section: params-5 -->

### פרמטרים

| שם | תיאור |
| --- | --- |
| `limit` | מספר שלם, רשות, ברירת המחדל היא 50. גודל העמוד |
| `offset` | מספר שלם, רשות, ברירת המחדל היא 0. היסט לצורך חלוקה לעמודים |

<!-- translation-section: example-5 -->

### דוגמה

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/threads?limit=50&offset=0'
```

<!-- translation-section: read-thread -->

## קריאת שרשור

קריאת שרשור, רצף האירועים המסודר שלו, או מסמך ה-Markdown המלא של התוכן הנגיש בו.

`GET /api/b2/threads/:topic_id`

`GET /api/b2/threads/:topic_id/items`

`GET /api/b2/threads/:topic_id/markdown`

<!-- translation-section: example-6 -->

### דוגמה

```text
GET https://www.loomio.com/api/b2/threads/<topic_id>
GET https://www.loomio.com/api/b2/threads/<topic_id>/items
GET https://www.loomio.com/api/b2/threads/<topic_id>/markdown
```

נקודת הקצה `items` מחזירה את רצף האירועים המסודר, כולל תגובות, סקרים, הצבעות ומסקנות הנגישים לחשבון. נקודת הקצה `markdown` מחזירה את כל התוכן הנגיש בשרשור כמסמך Markdown אחד. נימוקי ההצבעות נכללים רק כאשר הם נגישים לחשבון שמפתח ה-API שייך אליו.

כל נקודות הקצה של השרשורים אוכפות את אותן הרשאות כמו ממשק Loomio. מפתח ה-API אינו מעניק גישה לשרשור שאין לחשבון הרשאה לפתוח בדרך הרגילה.

<!-- translation-section: edit-discussion -->

## עריכת דיון

עריכת דיון בשם החשבון שמפתח ה-API שייך אליו. חלות אותן הרשאות כמו ב-Loomio: לחשבון חייבת להיות הרשאה לערוך את הדיון הזה.

`PATCH /api/b2/discussions/:id`

<!-- translation-section: params-6 -->

### פרמטרים

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

### דוגמה

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X PATCH -H 'Content-Type: application/json' -d '{"title":"updated thread title", "description":"updated context", "description_format":"md"}' https://www.loomio.com/api/b2/discussions/123
```

<!-- translation-section: soft-delete-discussion -->

## מחיקה רכה של דיון

מחיקה רכה של דיון בשם החשבון שמפתח ה-API שייך אליו. הפעולה מסירה את הדיון אך משאירה את רשומת הדיון במקומה.

`DELETE /api/b2/discussions/:id`

<!-- translation-section: example-8 -->

### דוגמה

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X DELETE https://www.loomio.com/api/b2/discussions/123
```

<!-- translation-section: create-comment -->

## יצירת תגובה

יצירת תגובה בדיון בשם החשבון שמפתח ה-API שייך אליו.

`POST /api/b2/comments`

<!-- translation-section: params-7 -->

### פרמטרים

| שם | תיאור |
| --- | --- |
| `discussion_id` | מספר שלם, חובה. מזהה הדיון שבו תפורסם התגובה |
| `body` | גוף התגובה, חובה אלא אם מצורף קובץ |
| `body_format` | `md` או `html`, רשות, ברירת המחדל היא `md` |

<!-- translation-section: example-9 -->

### דוגמה

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"discussion_id": 123, "body":"example comment", "body_format":"md"}' https://www.loomio.com/api/b2/comments
```

<!-- translation-section: edit-comment -->

## עריכת תגובה

עריכת תגובה בשם החשבון שמפתח ה-API שייך אליו. חלות אותן הרשאות כמו ב-Loomio: נדרשת לחשבון הרשאה לערוך את התגובה.

`PATCH /api/b2/comments/:id`

<!-- translation-section: params-8 -->

### פרמטרים

| שם | תיאור |
| --- | --- |
| `body` | גוף התגובה המעודכן |
| `body_format` | `md` או `html`, רשות, ברירת המחדל היא `md` |

<!-- translation-section: example-10 -->

### דוגמה

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X PATCH -H 'Content-Type: application/json' -d '{"body":"updated comment", "body_format":"md"}' https://www.loomio.com/api/b2/comments/123
```

<!-- translation-section: soft-delete-comment -->

## מחיקה רכה של תגובה

מחיקה רכה של תגובה בשם החשבון שמפתח ה-API שייך אליו. הפעולה מסירה את התגובה, מסתירה את גוף התגובה ומשאירה את רשומת התגובה במקומה.

`DELETE /api/b2/comments/:id`

<!-- translation-section: example-11 -->

### דוגמה

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X DELETE https://www.loomio.com/api/b2/comments/123
```

<!-- translation-section: create-poll -->

## יצירת סקר

יצירת סקר בשם החשבון שמפתח ה-API שייך אליו.

`POST /api/b2/polls`

<!-- translation-section: params-9 -->

### פרמטרים

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

### דוגמה

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "title":"example poll", "poll_type": "proposal", "options": ["agree", "disagree"], "closing_at": "2026-09-01T12:00:00Z", "recipient_emails":["person@example.com"]}' https://www.loomio.com/api/b2/polls
```

<!-- translation-section: show-poll -->

## הצגת סקר

אחזור סקר באמצעות מזהה הסקר, שהוא מספר שלם, או מפתח, שהוא מחרוזת.

`GET /api/b2/polls/:id`

<!-- translation-section: example-13 -->

### דוגמה

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/polls/abc123
```

<!-- translation-section: list-polls -->

## רשימת סקרים

הצגת רשימת הסקרים בקבוצה הגלויים לחשבון שמפתח ה־API שייך לו. בקבוצה הגלויה לציבור, ניתן לקבל את רשימת הסקרים הציבוריים גם ללא חברות בקבוצה; הגישה לסקרים פרטיים נשארת מוגבלת למשתמשים שיש להם הרשאה לקרוא אותם ב־Loomio. התשובה כוללת את המסקנה הנוכחית של כל סקר גלוי, כך שניתן להשתמש ב־`status=closed` לקבלת רשימת הצעות שהתקבלה לגביהן החלטה.

`GET /api/b2/polls`

<!-- translation-section: params-10 -->

### פרמטרים

| שם | תיאור |
| --- | --- |
| `group_id` | מספר שלם, חובה. מזהה הקבוצה שממנה יש להציג את רשימת הסקרים |
| `status` | מחרוזת, לא חובה, ברירת המחדל היא `active`. ערכים: `active`, `closed`, `all` |
| `limit` | מספר שלם, לא חובה, ברירת המחדל היא 50. גודל העמוד |
| `offset` | מספר שלם, לא חובה, ברירת המחדל היא 0. היסט לחלוקה לעמודים |

תאימות לאחור: `per` ו־`from` מתקבלים כשמות חלופיים ל־`limit` ול־`offset` וימשיכו לפעול.

<!-- translation-section: example-14 -->

### דוגמה

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/polls?group_id=123'
```

<!-- translation-section: edit-poll -->

## עריכת סקר

עריכת סקר בשם החשבון שמפתח ה־API שייך לו. חלות אותן הרשאות כמו ב־Loomio: לחשבון חייבת להיות הרשאה לערוך את הסקר.

`PATCH /api/b2/polls/:id`

<!-- translation-section: params-11 -->

### פרמטרים

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

### דוגמה

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X PATCH -H 'Content-Type: application/json' -d '{"title":"updated poll title", "details":"updated details", "details_format":"md"}' https://www.loomio.com/api/b2/polls/123
```

<!-- translation-section: soft-delete-poll -->

## מחיקה רכה של סקר

מחיקה רכה של סקר בשם החשבון שמפתח ה־API שייך לו. פעולה זו מסמנת את הסקר כמחוק ומשאירה את רשומת הסקר במקומה.

`DELETE /api/b2/polls/:id`

<!-- translation-section: example-16 -->

### דוגמה

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X DELETE https://www.loomio.com/api/b2/polls/123
```

<!-- translation-section: list-memberships -->

## רשימת חברויות

הצגת החברויות הגלויות לחשבון המשויך למפתח ה־API. חברי הקבוצה יכולים לקרוא את שמות החברים, המזהים, התארים והתפקידים שלהם. כתובות דוא״ל נכללות רק עבור החשבון המשויך למפתח ה־API עצמו, או כאשר לחשבון זה יש הרשאת ניהול בקבוצה.

`GET /api/b2/memberships`

<!-- translation-section: params-12 -->

### פרמטרים

| שם | תיאור |
| --- | --- |
| `group_id` | מספר שלם, חובה. מזהה הקבוצה שהחברויות בה יוצגו ברשימה |

<!-- translation-section: example-17 -->

### דוגמה

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/memberships?group_id=123'
```

<!-- translation-section: manage-memberships -->

## ניהול חברויות

יש לשלוח רשימה של כתובות דוא״ל. לכל הכתובות החדשות תישלח הזמנה לקבוצה. בניגוד להצגת רשימת חברויות, פעולה זו דורשת הרשאת ניהול בקבוצה.

`POST /api/b2/memberships`

<!-- translation-section: params-13 -->

### פרמטרים

| שם | תיאור |
| --- | --- |
| `group_id` | מספר שלם, חובה. מזהה הקבוצה שהחברויות בה ינוהלו |
| `emails` | מערך של מחרוזות, חובה. כתובות דוא״ל של אנשים שיש להזמין לקבוצה |
| `remove_absent` | ערך בוליאני. אם הערך הוא true, כל מי שכתובת הדוא״ל שלהם אינה מופיעה ברשימה יוסרו מהקבוצה |

<!-- translation-section: example-18 -->

### דוגמה

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "emails":["person@example.com"]}' https://www.loomio.com/api/b2/memberships
```

אם מועבר `remove_absent=1`, כל חברי הקבוצה שלא נכללו ברשימה יוסרו מהקבוצה. יש להיזהר: פעולה זו עלולה להסיר את כל חברי הקבוצה.

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "emails":["person@example.com"], "remove_absent": 1}' https://www.loomio.com/api/b2/memberships
```

הפעולה מחזירה אובייקט עם `{added_emails: ["person@added.com"], removed_emails: ["person@removed.com"]}`.
