---
title: API למשתמש
source_revision: 7a01b0fd7d7df0c4bca327a916b01b12e62b967f
source_file: docs/user_manual/integrations/api/user-api.md
translated:
  provider: codex/gpt-6-sol
  'on': '2026-09-30'
sections:
  introduction: a43c8b800d13fd33
  authentication-change: 06b5c2cd9d9e72a0
  response-size-and-related-records: 1ffc59ad606a87e7
  endpoint-summary: 52c480c59d3669e3
  groups: 0473f1f7fb78f074
  list-groups: 2b783ec54f27b2ce
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
  introduction: 9778753471623f26
  authentication-change: 0f1e52c8cf544ebf
  response-size-and-related-records: 3a78a75da5f67756
  endpoint-summary: b57ce9db383b39df
  groups: 05c42ae402e79755
  list-groups: 5e213b21ee944434
  get-a-group: 01201d1b302ddfe0
  webhooks: 834c41cb8b2fb109
  list-webhooks: 28c53984f1f23af6
  create-a-webhook: 38f4988c57010ece
  update-a-webhook: 6909092e5506c850
  test-a-webhook-destination: 797bd9362e5c4f85
  delete-a-webhook: 0f2063aee382563f
  event-types: e155a64c8bca21d2
  http-delivery: 4d5799271a391344
  payload-formats: 9f14ca02cbb5d760
  search: 5df6aad7d4471512
  params: 8edba7345ae77af3
  participation-report: 5c366c44cf88cf7c
  params-2: 7469cdfb3a46bc75
  example: a231af52382ab4b4
  create-discussion: dab28e085eae6a4c
  params-3: bca4bcee598f145f
  example-2: a9e2934fac9fe85b
  show-discussion: 2ec901594f4c11c2
  example-3: 9b68959346737a9f
  list-discussions: 224d303faf8cdefc
  params-4: 3d98faab296de94e
  example-4: 2ab92caa61cc2c64
  list-threads: 569dae9fa37b40e2
  params-5: 50387bdbd805beec
  example-5: c000286719036d3d
  read-thread: 8aa55795d2a50e2b
  example-6: 94fa35a936b63947
  edit-discussion: 506515aa006da312
  params-6: 36aa915b60ce625a
  example-7: 1452f7cf1715031d
  soft-delete-discussion: 109a63c25569186e
  example-8: 87b40795a210d4d4
  create-comment: d236b31c718e2227
  params-7: aa0280ccf1d7170b
  example-9: c6989ae0568989cb
  edit-comment: fecbf3296bf81c77
  params-8: 35eb1ac4b93f19b9
  example-10: d1825db5ab1b9e8a
  soft-delete-comment: 427b5bad900f0674
  example-11: 045335d89a7fb779
  create-poll: dd8bab82b08370ea
  params-9: 4c40e0a65bbb1ed7
  example-12: 218c20faadfec3c8
  show-poll: a7741542219ce709
  example-13: e271e6a44e58378f
  list-polls: 7e8ce10df1b0d157
  params-10: 0c9fd5e40f19eb13
  example-14: e1b869ce21cfc46b
  edit-poll: 27ec25865517f898
  params-11: 7e741908b85e9ecd
  example-15: f9539a1c7e692b04
  soft-delete-poll: 7b17c6783804e61d
  example-16: 06de09d9a51dfb6e
  list-memberships: a57658ba131bfbcb
  params-12: b95e43c9a2f23f6d
  example-17: 125d4adb5493a71d
  manage-memberships: 3079aae6bd6bd1e9
  params-13: 0a21086498ed37c4
  example-18: 4449208eed8a8ea6
title_source: c23fb6526b722360
title_generated: 2a1c5c279b64d7ea
---

<!-- translation-section: introduction -->

# תיעוד ה־API למשתמש של Loomio

<!-- seo-description: באמצעות ה־API למשתמש של Loomio ניתן ליצור ולנהל דיונים, תגובות, משאלים, שרשורים וחברויות בקבוצות מתוך תוכנות אחרות. -->

`/api/b2` הוא ה־API למשתמש עבור אינטגרציות עם Loomio. הוא משתמש במפתח ה־API של חשבון משתמש, וכל פעולה מתבצעת בשם החשבון הזה.

פעולות בקבוצות כפופות לחברויות ולהרשאות הקבוצה של החשבון שמפתח ה־API שייך לו. הרשאת ניהול של המערכת אינה מרחיבה את הגישה של מפתח ה־API לקבוצות או לתוכן. לניהול ברמת המערכת יש להשתמש ב־Server API.

יש להשתמש במפתח ה־API של חשבון Loomio שיבצע את הפעולות. חשבון בוט ייעודי מועיל כאשר אין צורך להזמין את האינטגרציה להשתתף במשאלים או לשלוח לה התראות.

לאחר כניסה לחשבון, ניתן למצוא את מפתח ה־API ואת מזהי הקבוצות ב[דף הגישה ל־API](/profile/api_access).

יש לשלוח את מפתח ה־API בכותרת `Authorization: Bearer`. מפתחות API שנשלחים בפרמטרים של כתובת URL נדחים, משום ששרתי תיווך ויומני גישה עשויים לתעד כתובות URL.

<!-- translation-section: authentication-change -->

### שינוי באופן האימות

בעבר ניתן היה לשלוח את מפתח ה־API בפרמטר הכתובת `api_key`. בקשות שמשתמשות ב־`?api_key=YOUR_API_KEY` אינן פועלות עוד. יש להשתמש בכותרת HTTP ‏`Authorization` במקום זאת:

```text
Authorization: Bearer YOUR_API_KEY
```

בדוגמאות נעשה שימוש ב־`YOUR_API_KEY`, במזהה הקבוצה `123` ובכתובת `https://www.loomio.com/`. יש להחליף אותם במפתח ה־API, במזהה הקבוצה ובכתובת ההתקנה של Loomio.

<!-- translation-section: response-size-and-related-records -->

## גודל התגובה ורשומות קשורות

תגובות ה־API למשתמש משתמשות במבנה משולב: לצד הרשומות הראשיות נשלחות רשומות קשורות, כגון נושאים, קבוצות, משתמשים, משאלים ותגובות רגשיות. כך אפשר למלא מאגר רשומות מקומי בבקשה אחת, אך התגובה עשויה להכיל יותר נתונים מהנדרש לאינטגרציה פשוטה.

ניתן להעביר `compact=1` כדי להשמיט רשומות קשורות גדולות של נושאים, קבוצות, קבוצות הורה, חברויות, תגובות רגשיות, תגיות ותרגומים. הרשומות הראשיות והרשומות הקשורות הנחוצות להבנת התוכן שלהן עדיין ייכללו.

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/threads/123/items?compact=1'
```

לשליטה ישירה, יש להעביר את `exclude_types` עם שמות סוגי רשומות ביחיד, מופרדים ברווחים. לדוגמה, `exclude_types=group reaction` משמיט קבוצות ותגובות רגשיות קשורות. ערכים נפוצים הם `topic`, `group`, `parent`, `membership`, `reaction`, `tag`, `translation`, `user`, `discussion`, `poll`, `poll_option`, `stance`, `stance_choice`, `outcome` ו־`topic_item`. ההשמטות חלות על רשומות קשורות, ולא על המשאב הראשי שהתבקש בנקודת הקצה.

תגובות של אוספים כוללות את `meta.total` כאשר מוגדר גודל מדויק לאוסף. הסכום הכולל מחושב לפני החלת `limit` ו־`offset`. נקודות קצה כגון חיפוש, שמחזירות בכוונה מספר מוגבל של תוצאות, משמיטות את `meta.total` במקום להחזיר `null`.

<!-- translation-section: endpoint-summary -->

## סיכום נקודות הקצה

| שיטה | נקודת קצה | מטרה |
| --- | --- | --- |
| `GET` | `/api/b2/groups` | הצגת הקבוצות של החשבון שמפתח ה־API שייך לו |
| `GET` | `/api/b2/groups/:id_or_key_or_handle` | קבלת קבוצה שניתן לצפות בה |
| `GET` | `/api/b2/reports` | הפקת דוח השתתפות |
| `GET` | `/api/b2/search` | חיפוש בדיונים, בתגובות, במשאלים, בהצבעות ובמסקנות שניתן לצפות בהם |
| `POST` | `/api/b2/discussions` | יצירת דיון |
| `GET` | `/api/b2/discussions/:id` | קבלת דיון |
| `GET` | `/api/b2/discussions` | הצגת דיונים בקבוצה |
| `PATCH` | `/api/b2/discussions/:id` | עריכת דיון |
| `DELETE` | `/api/b2/discussions/:id` | מחיקה רכה של דיון |
| `GET` | `/api/b2/threads` | הצגת שרשורים של דיונים ושל משאלים עצמאיים שניתן לצפות בהם |
| `GET` | `/api/b2/threads/:topic_id` | קבלת שרשור |
| `GET` | `/api/b2/threads/:topic_id/items` | קבלת הפריטים בשרשור לפי סדרם |
| `GET` | `/api/b2/threads/:topic_id/markdown` | קבלת שרשור מלא בפורמט Markdown |
| `POST` | `/api/b2/comments` | יצירת תגובה או מענה |
| `PATCH` | `/api/b2/comments/:id` | עריכת תגובה |
| `DELETE` | `/api/b2/comments/:id` | מחיקה רכה של תגובה |
| `POST` | `/api/b2/polls` | יצירת משאל |
| `GET` | `/api/b2/polls/:id` | קבלת משאל |
| `GET` | `/api/b2/polls` | הצגת משאלים בקבוצה |
| `PATCH` | `/api/b2/polls/:id` | עריכת משאל |
| `DELETE` | `/api/b2/polls/:id` | מחיקה רכה של משאל |
| `GET` | `/api/b2/memberships` | הצגת החברויות בקבוצה |
| `POST` | `/api/b2/memberships` | הוספת חברים, ואפשרות להסיר חברים שאינם ברשימה |
| `GET` | `/api/b2/chatbots` | הצגת אינטגרציות הצ'אט וה־webhooks של קבוצה |
| `POST` | `/api/b2/chatbots` | יצירת אינטגרציית צ'אט או webhook |
| `PATCH` | `/api/b2/chatbots/:id` | עדכון אינטגרציית צ'אט או webhook |
| `DELETE` | `/api/b2/chatbots/:id` | מחיקת אינטגרציית צ'אט או webhook |
| `POST` | `/api/b2/chatbots/check` | שליחת בדיקת חיבור ל־webhook |

<!-- translation-section: groups -->

## קבוצות

<!-- translation-section: list-groups -->

### הצגת קבוצות

מחזיר את הקבוצות שבהן לחשבון שמפתח ה־API שייך לו יש חברות פעילה.

`GET /api/b2/groups`

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/groups
```

התגובה מכילה את כל הרשומות המתאימות במערך `groups`, ללא חלוקה לעמודים. היא כוללת קבוצות הורה ותת־קבוצות, גם כאשר המינוי שלהן אינו פעיל כרגע. כאשר האינטגרציה אמורה לפעול רק בקבוצות פעילות, יש לבדוק את השדה `enabled`.

שדות חשובים של קבוצה:

| שדה | תיאור |
| --- | --- |
| `id` | מזהה מספרי של הקבוצה, המשמש בנקודות קצה אחרות של ה־API למשתמש |
| `key` | מפתח קצר וקבוע המשמש בכתובות URL של Loomio |
| `handle` | מזהה קריא של הקבוצה |
| `name` | שם הקבוצה |
| `full_name` | שם הקבוצה, כולל ההקשר של קבוצת ההורה שלה |
| `parent_id` | המזהה המספרי של קבוצת ההורה של תת־קבוצה, או `null` אם אין קבוצת הורה |
| `enabled` | האם הקבוצה והמינוי שלה פעילים |
| `memberships_count` | מספר החברויות הפעילות והממתינות |
| `accepted_memberships_count` | מספר החברויות שאושרו |
| `pending_memberships_count` | מספר ההזמנות הממתינות |
| `admin_memberships_count` | מספר מנהלי הקבוצה |
| `delegates_count` | מספר הנציגים |
| `discussions_count` | מספר הדיונים ישירות בקבוצה |
| `polls_count` | מספר המשאלים ישירות בקבוצה |
| `subgroups_count` | מספר תת־הקבוצות |

התגובה עשויה לכלול הגדרות קבוצה נוספות, רשומות קשורות של קבוצת ההורה וחברויות של חשבון ה־API. על תוכנות המשתמשות ב־API להתעלם משדות שאינן משתמשות בהם.

<!-- translation-section: get-a-group -->

### קבלת קבוצה

מחזיר קבוצה אחת שהחשבון שמפתח ה־API שייך לו יכול לצפות בה.

`GET /api/b2/groups/:id_or_key_or_handle`

המזהה יכול להיות המזהה המספרי של הקבוצה, המפתח שלה או המזהה הקריא שלה.

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/groups/123
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/groups/example-group
```

התגובה מכילה את הקבוצה במערך `groups`, עם אותם שדות כמו בנקודת הקצה להצגת קבוצות. בקשה לקבוצה שאין לחשבון שמפתח ה־API שייך לו גישה אליה מחזירה שגיאת הרשאה.

<!-- translation-section: webhooks -->

## Webhooks

ה־API למשתמש מבוסס על בקשות: אינטגרציה פונה ל־Loomio כאשר היא צריכה לקרוא או לשנות נתונים. Webhook של קבוצה מאפשר לשלוח עדכונים בכיוון ההפוך. Loomio שולח אירועים נבחרים מהקבוצה לנקודת הקצה של האינטגרציה כשהם מתרחשים, כך שאין צורך לבדוק שוב ושוב אם חלו שינויים ב־REST API.

Webhooks מוגדרים לכל קבוצה בנפרד ודורשים הרשאת ניהול בקבוצה. ניתן לנהל אותם דרך הממשק של Loomio:

1. יש לפתוח את הקבוצה.
2. יש לפתוח את תפריט הקבוצה ולבחור **אינטגרציות צ'אט**.
3. יש להוסיף אינטגרציה שמתאימה לפורמט הנתונים שנקודת הקצה מקבלת. לנקודת קצה כללית, יש להשתמש בפורמט Mattermost/Markdown.
4. יש להזין שם ואת כתובת ה־URL של היעד.
5. יש לבחור את האירועים ש־Loomio ישלח אוטומטית.
6. יש לשמור את האינטגרציה ולהשתמש ב־**בדיקת חיבור** כדי לשלוח הודעת בדיקה.

יש להשתמש ביעד HTTPS עם כתובת URL שקשה לנחש. Loomio דורש שכתובת היעד תפנה לכתובת ציבורית וחוסם בקשות לכתובות ברשת מקומית או פרטית.

אפשר לנהל webhooks גם באמצעות סוכנים ואינטגרציות אחרות, דרך נקודות הקצה של צ'אטבוטים המאומתות באמצעות Bearer ומתוארות בהמשך. המשאב נקרא `chatbots` כדי לשמור על תאימות לאינטגרציות הצ'אט של Loomio, והוא משמש גם ל-webhooks יוצאים כלליים.

<!-- translation-section: list-webhooks -->

### הצגת webhooks

מחזיר את אינטגרציות הצ'אט שהוגדרו לקבוצה. נדרשת הרשאת ניהול בקבוצה עבור החשבון שמפתח ה־API שייך לו. התגובה כוללת כתובות URL של יעדים, ולכן אין לחשוף אותה לחברי קבוצה שאינם מנהלים.

`GET /api/b2/chatbots?group_id=123`

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/chatbots?group_id=123'
```

התגובה מכילה מערך `chatbots` עם השדות הבאים:

| שדה | תיאור |
| --- | --- |
| `id` | מזהה האינטגרציה המשמש לעדכון ולמחיקה |
| `group_id` | הקבוצה שממנה מתקבלים האירועים |
| `name` | השם של האינטגרציה לצורכי ניהול |
| `kind` | `webhook` עבור webhook יוצא או `matrix` עבור אינטגרציית Matrix |
| `webhook_kind` | פורמט הנתונים: `markdown`, `slack`, `discord`, `microsoft` או `webex` |
| `server` | כתובת ה-URL של היעד |
| `event_kinds` | אירועים שנשלחים אוטומטית |
| `notification_only` | האם ההודעות כוללות רק את כותרת ההתראה |

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

חשבון המשתמש של מפתח ה-API חייב להיות בעל הרשאות ניהול בקבוצה `group_id`. לפני השמירה נבדק שכתובת ה-URL של היעד ציבורית.

<!-- translation-section: update-a-webhook -->

### עדכון webhook

`PATCH /api/b2/chatbots/:id`

יש לשלוח את השדות שיש לשנות. שינוי `group_id` אינו מאפשר להעביר את ה-webhook לקבוצה אחרת.

```bash
curl -X PATCH \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"name":"Planning events","event_kinds":["new_discussion","outcome_created"]}' \
  https://www.loomio.com/api/b2/chatbots/456
```

<!-- translation-section: test-a-webhook-destination -->

### בדיקת יעד של webhook

ניתן לשלוח ליעד הודעת בדיקה התואמת ל-Markdown לפני שמירת ההגדרות או אחריה.

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

מחיקת ההגדרות מפסיקה משלוחים עתידיים. היא אינה מוחקת תוכן מהקבוצה ב-Loomio.

<!-- translation-section: event-types -->

### סוגי אירועים

ניתן להירשם באמצעות webhook לסוגי האירועים הבאים:

| אירוע | מתי הוא נשלח |
| --- | --- |
| `new_discussion` | נפתח דיון |
| `discussion_edited` | דיון נערך |
| `new_comment` | נוצרה תגובה |
| `poll_created` | נפתח משאל |
| `poll_edited` | משאל נערך |
| `poll_closing_soon` | מועד סגירת המשאל מתקרב |
| `poll_expired` | הגיע מועד סגירת המשאל |
| `poll_closed_by_user` | המשאל נסגר ידנית |
| `poll_reopened` | המשאל נפתח מחדש |
| `outcome_created` | פורסמה מסקנה |
| `outcome_updated` | מסקנה עודכנה |
| `outcome_review_due` | הגיע המועד לבדיקת מסקנה |
| `stance_created` | הוצבעה הצבעה |
| `stance_updated` | הצבעה שונתה |

ה-webhook שייך לקבוצה אחת ומקבל ממנה את האירועים שנבחרו. ניתן גם לבחור במפורש באינטגרציה בעת שיתוף או שליחה של התראות מסוימות, גם אם האירוע האוטומטי המתאים לא נבחר.

<!-- translation-section: http-delivery -->

### משלוח באמצעות HTTP

Loomio שולחת בקשת HTTP מסוג `POST` באופן אסינכרוני לכתובת ה-URL שהוגדרה, עם הכותרת הבאה:

```text
Content-Type: application/json; charset=utf-8
```

זמן ההמתנה המרבי לבקשה הוא חמש שניות. תגובת `2xx`, כולל `204 No Content`, נחשבת להצלחה. שירותים שמקבלים הודעות webhook צריכים להשיב במהירות, לעבד פעולות ממושכות באופן אסינכרוני ולהתמודד עם משלוחים כפולים או משלוחים שמגיעים בסדר שונה.

Loomio אינה מוסיפה כיום חתימת webhook, כותרת עם סוד משותף, מזהה אירוע או מזהה משלוח. יש להתייחס לכתובת ה-URL המלאה של היעד כאל פרט גישה, להימנע מחשיפתה לציבור ולכלול בה אסימון שקשה לנחש אם השירות המקבל תומך בכך. אם נדרשים מבנה אירועים יציב לקריאה ממוחשבת או משלוחים חתומים, ניתן להשתמש ב-webhook כהודעה על שינוי ולאחזר את הרשומות העדכניות דרך ממשק ה-API למשתמשים עם אימות.

<!-- translation-section: payload-formats -->

### פורמטים של הנתונים הנשלחים

הנתונים שנשלחים ב-webhook הם הודעות המיועדות להצגה בשירותי צ'אט. הם אינם רשומות Loomio מלאות בפורמט סדור. הקישורים בהודעה מזהים את התוכן שהושפע ב-Loomio; כשנדרש המצב העדכני במבנה נתונים, ניתן לאחזר אותו דרך ממשק ה-API למשתמשים.

| פורמט האינטגרציה | שדות JSON עיקריים |
| --- | --- |
| Mattermost/Markdown | `text`, `icon_url`, `username` |
| Slack | `text` |
| Discord | `content`, מוגבל לכ-1,900 תווים |
| Microsoft Teams | `@type`, `@context`, `themeColor`, `text`, `sections` |
| Webex | `markdown` |

לדוגמה, הפורמט הכללי של Markdown שולח גוף הודעה במבנה הבא:

```json
{
  "text": "Ada started a discussion: [Quarterly planning](https://example.loomio.org/d/example)",
  "icon_url": "https://example.loomio.org/path/to/group-logo.png",
  "username": "Loomio"
}
```

נוסח ההודעה המדויק תלוי באירוע, בשפת הקבוצה, בהגדרה לשליחת כותרת ההתראה בלבד ובגרסת Loomio. יש להסתמך על השדות הראשיים המתועדים של הפורמט שנבחר, ולא על ניתוח נוסח המשפטים.

<!-- translation-section: search -->

## חיפוש

ניתן לחפש דיונים, תגובות, משאלים, הצבעות ומסקנות שגלויים לחשבון המשתמש של מפתח ה-API. התוצאות כוללות תוכן ציבורי גם ללא חברות בקבוצה שלו. הגישה לתוכן פרטי כפופה לכללי הנראות הרגילים של הנושא.

`GET /api/b2/search`

<!-- translation-section: params -->

### פרמטרים

| שם | תיאור |
| --- | --- |
| `query` | טקסט לחיפוש. נתמכות התאמות מדויקות ומקורבות |
| `group_id` | הגבלת התוצאות לקבוצה גלויה אחת |
| `org_id` | הגבלת התוצאות לקבוצת אם גלויה ולתתי-הקבוצות הגלויות שלה. עבור דיונים ישירים יש להשתמש ב-`0` |
| `type` | הגבלת התוצאות לסוג אחד: `Discussion`, `Comment`, `Poll`, `Stance` או `Outcome` |
| `types` | רשימת סוגי תוצאות מופרדת בפסיקים |
| `tag` | הגבלת התוצאות לנושאים עם התג הזה |
| `author_id` | הגבלת התוצאות לתוכן של מחבר או מחברת מסוימים. ללא `query`, מוחזרת הפעילות הגלויה האחרונה של אותו חשבון |
| `order` | יש להגדיר `authored_at_desc` כדי לסדר תוכן תואם לפי זמן היצירה |

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/search?query=quarterly+planning&type=Discussion'
```

התגובה מכילה מערך `search_results`. כל תוצאה מזהה את הרשומה שנמצאה ואת ההקשר הגלוי שלה באמצעות שדות כגון `searchable_type`, `searchable_id`, `highlight`, `group_id`, `group_name`, `discussion_key`, `poll_key`, `author_id`, `author_name`, `authored_at` ו-`tags`. שדות שאינם חלים על תוצאה מסוימת מקבלים את הערך `null`.

<!-- translation-section: participation-report -->

## דוח השתתפות

החזרת אותם נתוני השתתפות מצטברים שבהם משתמש דוח ההשתתפות של Loomio.

`GET /api/b2/reports`

<!-- translation-section: params-2 -->

### פרמטרים

| שם | תיאור |
| --- | --- |
| `section` | חלק בדוח: `base`, `users` או `countries`. עבור פעילות של כל אדם בנפרד יש להשתמש ב-`users` |
| `group_scope` | `custom` או `my`. הערך הישן `all` מטופל כמו `my`, כי מפתחות API למשתמשים אינם מקנים גישה לכל המערכת |
| `group_ids` | מזהי קבוצות מופרדים בפסיקים כאשר `group_scope=custom`. מזהים של קבוצות שחשבון ה-API אינו חבר בהן אינם נכללים |
| `start_month` | החודש הראשון שייכלל בפורמט `YYYY-MM`; ברירת המחדל היא לפני 12 חודשים |
| `end_month` | החודש האחרון שייכלל בפורמט `YYYY-MM`; ברירת המחדל היא החודש הנוכחי |
| `interval` | מרווח הזמן עבור החלק `base`: `day`, `week`, `month` או `year` |
| `member_type` | כדי להחזיר רק נציגים ונציגות נוכחיים, יש להגדיר `delegate` יחד עם `section=users` |

אדם נחשב לנציג או לנציגה כאשר יש לו חברות פעילה בתפקיד זה באחת הקבוצות שנבחרו. הספירות מצטברות מכל הקבוצות שנבחרו. שורות של נציגים ונציגות מוחזרות גם כשכל ספירות הפעילות הן אפס. הספירות כוללות שרשורים, תגובות, משאלים, הצבעות, מסקנות ותגובות רגשיות; הן אינן שיעורי השתתפות בהצבעה. שורות המשתמשים כוללות גם פתקי הצבעה מזוהים שהונפקו, שמולאו ושלא מולאו. משאלים אנונימיים אינם נכללים באף ספירת הצבעה אישית. הערך של `all_votes_cast` הוא true רק אם הונפק לפחות פתק הצבעה אחד וכל הפתקים שהונפקו מולאו.

ממשק ה-API מחיל את אותם כללי נראות של קבוצות שחלים על הדוח ב-Loomio. מפתח API של משתמש אינו יכול לחשוף נתוני דוח מקבוצות שלחשבון המשתמש אין גישה אליהן.

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

יצירת דיון בשם המשתמש או המשתמשת שהנפיקו את מפתח ה־API.

`POST /api/b2/discussions`

<!-- translation-section: params-3 -->

### פרמטרים

| שם | תיאור |
| --- | --- |
| `group_id` | הקבוצה שבה השרשור יופיע |
| `title` | כותרת השרשור, שדה חובה |
| `description` | רקע לשרשור, שדה רשות |
| `description_format` | `md` או `html`, שדה רשות. ברירת המחדל היא `md` |
| `recipient_audience` | `group` או null. אם הערך הוא `group`, תישלח הודעה לכל הקבוצה על השרשור החדש |
| `recipient_user_ids` | מערך מזהי משתמשים שיש לשלוח להם הודעה או להזמין אותם לשרשור |
| `recipient_emails` | מערך כתובות דוא״ל של אנשים שיש להזמין לשרשור |
| `recipient_message` | הודעה שתיכלל בהזמנה בדוא״ל |

<!-- translation-section: example-2 -->

### דוגמה

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "title":"example thread", "recipient_emails":["person@example.com"]}' https://www.loomio.com/api/b2/discussions
```

<!-- translation-section: show-discussion -->

## הצגת דיון

אחזור דיון לפי מזהה מספרי או לפי מפתח שהוא מחרוזת.

`GET /api/b2/discussions/:id`

<!-- translation-section: example-3 -->

### דוגמה

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/discussions/abc123
```

<!-- translation-section: list-discussions -->

## רשימת דיונים

הצגת הדיונים בקבוצה שגלויים לחשבון המשויך למפתח ה־API. בקבוצה שגלויה לציבור, גם מי שאינם חברי הקבוצה יכולים להציג את הדיונים הציבוריים שלה. דיונים פרטיים גלויים רק למי שרשאים לקרוא אותם ב־Loomio.

`GET /api/b2/discussions`

<!-- translation-section: params-4 -->

### פרמטרים

| שם | תיאור |
| --- | --- |
| `group_id` | מספר שלם, שדה חובה. מזהה הקבוצה שאת הדיונים שלה יש להציג |
| `status` | מחרוזת, שדה רשות. ברירת המחדל היא `open`. ערכים אפשריים: `open`, `closed`, `all` |
| `limit` | מספר שלם, שדה רשות. ברירת המחדל היא 50. גודל העמוד |
| `offset` | מספר שלם, שדה רשות. ברירת המחדל היא 0. נקודת ההתחלה של העימוד |

תאימות לאחור: `per` ו־`from` מתקבלים כשמות חלופיים ל־`limit` ול־`offset`, וימשיכו לפעול.

<!-- translation-section: example-4 -->

### דוגמה

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/discussions?group_id=123'
```

<!-- translation-section: list-threads -->

## רשימת שרשורים

הצגת שרשורי הדיונים והסקרים שגלויים לחשבון המשויך למפתח ה־API, לפי מועד הפעילות האחרונה. מזהה השרשור הוא ה־`topic_id` שלו.

`GET /api/b2/threads`

<!-- translation-section: params-5 -->

### פרמטרים

| שם | תיאור |
| --- | --- |
| `limit` | מספר שלם, שדה רשות. ברירת המחדל היא 50. גודל העמוד |
| `offset` | מספר שלם, שדה רשות. ברירת המחדל היא 0. נקודת ההתחלה של העימוד |

<!-- translation-section: example-5 -->

### דוגמה

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/threads?limit=50&offset=0'
```

<!-- translation-section: read-thread -->

## קריאת שרשור

קריאת שרשור, רצף האירועים שלו לפי סדרם או מסמך Markdown מלא של התוכן הגלוי בו.

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

נקודת הקצה `items` מחזירה את רצף האירועים לפי סדרם, ובכלל זה תגובות, סקרים, הצבעות ומסקנות גלויים. נקודת הקצה `markdown` מחזירה את כל התוכן הגלוי בשרשור כמסמך Markdown אחד. נימוקי הצבעה נכללים רק אם הם גלויים לחשבון המשויך למפתח ה־API.

כל נקודות הקצה של שרשורים אוכפות את אותן הרשאות שחלות בממשק Loomio. מפתח ה־API אינו מעניק גישה לשרשור שאי אפשר לפתוח באמצעות החשבון כרגיל.

<!-- translation-section: edit-discussion -->

## עריכת דיון

עריכת דיון בשם החשבון המשויך למפתח ה־API. חלות אותן הרשאות כמו ב־Loomio: לחשבון חייבת להיות הרשאה לערוך את הדיון.

`PATCH /api/b2/discussions/:id`

<!-- translation-section: params-6 -->

### פרמטרים

| שם | תיאור |
| --- | --- |
| `title` | כותרת מעודכנת |
| `description` | רקע מעודכן |
| `description_format` | `md` או `html`, שדה רשות. ברירת המחדל היא `md` |
| `recipient_audience` | `group` או null. אם הערך הוא `group`, תישלח הודעה לכל הקבוצה על העריכה |
| `recipient_user_ids` | מערך מזהי משתמשים שיש לשלוח להם הודעה או להזמין אותם לשרשור |
| `recipient_emails` | מערך כתובות דוא״ל של אנשים שיש להזמין לשרשור |
| `recipient_message` | הודעה שתיכלל בהזמנה בדוא״ל |

<!-- translation-section: example-7 -->

### דוגמה

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X PATCH -H 'Content-Type: application/json' -d '{"title":"updated thread title", "description":"updated context", "description_format":"md"}' https://www.loomio.com/api/b2/discussions/123
```

<!-- translation-section: soft-delete-discussion -->

## מחיקה רכה של דיון

מחיקה רכה של דיון בשם החשבון המשויך למפתח ה־API. הפעולה מסירה את הדיון מהתצוגה ומשאירה את הרשומה שלו במערכת.

`DELETE /api/b2/discussions/:id`

<!-- translation-section: example-8 -->

### דוגמה

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X DELETE https://www.loomio.com/api/b2/discussions/123
```

<!-- translation-section: create-comment -->

## יצירת תגובה

יצירת תגובה בדיון בשם החשבון המשויך למפתח ה־API.

`POST /api/b2/comments`

<!-- translation-section: params-7 -->

### פרמטרים

| שם | תיאור |
| --- | --- |
| `discussion_id` | מספר שלם, שדה חובה. מזהה הדיון שבו תפורסם התגובה |
| `body` | תוכן התגובה, שדה חובה אלא אם צורף קובץ |
| `body_format` | `md` או `html`, שדה רשות. ברירת המחדל היא `md` |

<!-- translation-section: example-9 -->

### דוגמה

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"discussion_id": 123, "body":"example comment", "body_format":"md"}' https://www.loomio.com/api/b2/comments
```

<!-- translation-section: edit-comment -->

## עריכת תגובה

עריכת תגובה בשם החשבון המשויך למפתח ה־API. חלות אותן הרשאות כמו ב־Loomio: לחשבון חייבת להיות הרשאה לערוך את התגובה.

`PATCH /api/b2/comments/:id`

<!-- translation-section: params-8 -->

### פרמטרים

| שם | תיאור |
| --- | --- |
| `body` | תוכן התגובה המעודכן |
| `body_format` | `md` או `html`, שדה רשות. ברירת המחדל היא `md` |

<!-- translation-section: example-10 -->

### דוגמה

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X PATCH -H 'Content-Type: application/json' -d '{"body":"updated comment", "body_format":"md"}' https://www.loomio.com/api/b2/comments/123
```

<!-- translation-section: soft-delete-comment -->

## מחיקה רכה של תגובה

מחיקה רכה של תגובה בשם החשבון המשויך למפתח ה־API. הפעולה מסירה את התגובה מהתצוגה, מסתירה את תוכנה ומשאירה את הרשומה שלה במערכת.

`DELETE /api/b2/comments/:id`

<!-- translation-section: example-11 -->

### דוגמה

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X DELETE https://www.loomio.com/api/b2/comments/123
```

<!-- translation-section: create-poll -->

## יצירת משאל

יצירת משאל באמצעות חשבון המשתמש המשויך למפתח ה-API.

`POST /api/b2/polls`

<!-- translation-section: params-9 -->

### פרמטרים

| שם | תיאור |
| --- | --- |
| `group_id` | מספר שלם, לא חובה, ברירת המחדל היא null. מזהה הקבוצה של המשאל. אם נשלח `discussion_id`, המערכת מתעלמת מ-`group_id` |
| `discussion_id` | מספר שלם, לא חובה, ברירת המחדל היא null. מזהה שרשור הדיון שאליו יתווסף המשאל |
| `title` | מחרוזת, חובה. כותרת המשאל |
| `poll_type` | מחרוזת, חובה. ערכים: `proposal`, `poll`, `count`, `score`, `ranked_choice`, `meeting`, `dot_vote` |
| `details` | מחרוזת, לא חובה. תוכן המשאל |
| `details_format` | מחרוזת, לא חובה, ברירת המחדל היא `md`. ערכים: `md` או `html` |
| `options` | מערך מחרוזות. אם `poll_type` הוא `proposal`, הערכים התקינים הם `agree`, `disagree`, `abstain`, `block`. אם `poll_type` הוא `meeting`, יש לספק תאריך או תאריך ושעה בפורמט ISO 8601. בכל סוגי המשאל האחרים, כל מחרוזת תקינה |
| `closing_at` | מחרוזת בפורמט ISO 8601 או null, ברירת המחדל היא null. לדוגמה: `2026-09-01T12:00:00Z`. אם הערך הוא null, ההצבעה מושבתת והמשאל נחשב לטיוטה |
| `specified_voters_only` | ערך בוליאני, לא חובה, ברירת המחדל היא false. אם הערך הוא true, רק אנשים שצוינו יכולים להצביע. אם הערך הוא false, כל חברי הקבוצה יוזמנו להצביע |
| `hide_results` | מחרוזת, לא חובה, ברירת המחדל היא `off`. ערכים: `off`, `until_vote`, `until_closed` |
| `shuffle_options` | ערך בוליאני, ברירת המחדל היא false. הצגת האפשרויות למצביעים בסדר אקראי |
| `anonymous` | ערך בוליאני, לא חובה, ברירת המחדל היא false. הסתרת זהות המצביעים |
| `recipient_audience` | `group` או null, לא חובה, ברירת המחדל היא null. אם הערך הוא `group`, כל הקבוצה תקבל הודעה |
| `notify_on_closing_soon` | מחרוזת, לא חובה, ברירת המחדל היא `nobody`. ערכים: `nobody`, `author`, `undecided_voters`, `voters` |
| `recipient_user_ids` | מערך מזהי משתמשים שיש להודיע להם או להזמין אותם |
| `recipient_emails` | מערך כתובות דוא״ל של אנשים שיש להזמין להצביע |
| `recipient_message` | הודעה שתיכלל בהזמנה בדוא״ל |
| `notify_recipients` | ערך בוליאני, ברירת המחדל היא false. אם הערך הוא false, אנשים יתווספו בלי לשלוח הודעות. אם הערך הוא true, כל מי שיוזמן בבקשה זו יקבל הודעה בדוא״ל |

<!-- translation-section: example-12 -->

### דוגמה

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "title":"example poll", "poll_type": "proposal", "options": ["agree", "disagree"], "closing_at": "2026-09-01T12:00:00Z", "recipient_emails":["person@example.com"]}' https://www.loomio.com/api/b2/polls
```

<!-- translation-section: show-poll -->

## הצגת משאל

אחזור משאל לפי מזהה מספרי או לפי מפתח שהוא מחרוזת.

`GET /api/b2/polls/:id`

<!-- translation-section: example-13 -->

### דוגמה

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/polls/abc123
```

<!-- translation-section: list-polls -->

## רשימת משאלים

הצגת המשאלים בקבוצה שחשבון המשתמש המשויך למפתח ה-API יכול לראות. בקבוצה שגלויה לציבור, גם מי שאינם חברי הקבוצה יכולים להציג את המשאלים הציבוריים שלה. משאלים פרטיים גלויים רק למי שיש להם הרשאה לקרוא אותם ב-Loomio. התגובה כוללת את המסקנה הנוכחית של כל משאל גלוי, כך שניתן להשתמש ב-`status=closed` כדי להציג הצעות שהתקבלה לגביהן החלטה.

`GET /api/b2/polls`

<!-- translation-section: params-10 -->

### פרמטרים

| שם | תיאור |
| --- | --- |
| `group_id` | מספר שלם, חובה. מזהה הקבוצה שאת המשאלים שלה יש להציג |
| `status` | מחרוזת, לא חובה, ברירת המחדל היא `active`. ערכים: `active`, `closed`, `all` |
| `limit` | מספר שלם, לא חובה, ברירת המחדל היא 50. גודל הדף |
| `offset` | מספר שלם, לא חובה, ברירת המחדל היא 0. היסט לחלוקה לדפים |

תאימות לאחור: `per` ו־`from` מתקבלים כשמות חלופיים ל־`limit` ול־`offset`, וימשיכו לפעול.

<!-- translation-section: example-14 -->

### דוגמה

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/polls?group_id=123'
```

<!-- translation-section: edit-poll -->

## עריכת משאל

עריכת משאל באמצעות חשבון המשתמש המשויך למפתח ה-API. חלות אותן הרשאות כמו ב-Loomio: נדרשת הרשאה לערוך את המשאל.

`PATCH /api/b2/polls/:id`

<!-- translation-section: params-11 -->

### פרמטרים

| שם | תיאור |
| --- | --- |
| `title` | כותרת מעודכנת |
| `details` | פרטי משאל מעודכנים |
| `details_format` | `md` או `html`, לא חובה, ברירת המחדל היא `md` |
| `options` | שמות מעודכנים של האפשרויות. שינוי האפשרויות עשוי להשפיע על הצבעות קיימות, בהתאם למצב המשאל |
| `closing_at` | מחרוזת בפורמט ISO 8601 או null |
| `recipient_audience` | `group` או null. אם הערך הוא `group`, כל הקבוצה תקבל הודעה |
| `recipient_user_ids` | מערך מזהי משתמשים שיש להודיע להם או להזמין אותם |
| `recipient_emails` | מערך כתובות דוא״ל של אנשים שיש להזמין להצביע |
| `recipient_message` | הודעה שתיכלל בהזמנה בדוא״ל |

<!-- translation-section: example-15 -->

### דוגמה

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X PATCH -H 'Content-Type: application/json' -d '{"title":"updated poll title", "details":"updated details", "details_format":"md"}' https://www.loomio.com/api/b2/polls/123
```

<!-- translation-section: soft-delete-poll -->

## מחיקה רכה של משאל

מחיקה רכה של משאל באמצעות חשבון המשתמש המשויך למפתח ה-API. הפעולה מסירה את המשאל מהתצוגה אך משאירה את הרשומה שלו.

`DELETE /api/b2/polls/:id`

<!-- translation-section: example-16 -->

### דוגמה

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X DELETE https://www.loomio.com/api/b2/polls/123
```

<!-- translation-section: list-memberships -->

## רשימת חברויות

הצגת החברויות שחשבון המשתמש המשויך למפתח ה-API יכול לראות. חברי קבוצה יכולים לקרוא את השמות, המזהים, התארים והתפקידים של חברי הקבוצה. כתובות דוא״ל נכללות רק עבור החשבון המשויך למפתח ה-API, או כאשר חשבון זה הוא מנהל קבוצה.

`GET /api/b2/memberships`

<!-- translation-section: params-12 -->

### פרמטרים

| שם | תיאור |
| --- | --- |
| `group_id` | מספר שלם, חובה. מזהה הקבוצה שאת החברויות שלה יש להציג |

<!-- translation-section: example-17 -->

### דוגמה

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/memberships?group_id=123'
```

<!-- translation-section: manage-memberships -->

## ניהול חברויות

יש לשלוח רשימת כתובות דוא״ל. כתובות חדשות ברשימה יקבלו הזמנה לקבוצה. בשונה מהצגת חברויות, פעולה זו דורשת הרשאת מנהל קבוצה.

`POST /api/b2/memberships`

<!-- translation-section: params-13 -->

### פרמטרים

| שם | תיאור |
| --- | --- |
| `group_id` | מספר שלם, חובה. מזהה הקבוצה שאת החברויות שלה יש לנהל |
| `emails` | מערך מחרוזות, חובה. כתובות הדוא״ל של אנשים שיש להזמין לקבוצה |
| `remove_absent` | ערך בוליאני. אם הערך הוא true, כל מי שכתובת הדוא״ל שלהם אינה מופיעה ברשימה יוסרו מהקבוצה |

<!-- translation-section: example-18 -->

### דוגמה

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "emails":["person@example.com"]}' https://www.loomio.com/api/b2/memberships
```

אם נשלח `remove_absent=1`, כל חברי הקבוצה שאינם כלולים ברשימה יוסרו ממנה. פעולה זו עלולה להסיר את כל חברי הקבוצה.

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "emails":["person@example.com"], "remove_absent": 1}' https://www.loomio.com/api/b2/memberships
```

הפעולה מחזירה אובייקט עם `{added_emails: ["person@added.com"], removed_emails: ["person@removed.com"]}`.
