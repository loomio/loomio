---
title: API השרת
source_revision: 81fbad246f674a34694bb2ebfc8416dd04e46ee6
source_file: docs/help/en/user_manual/integrations/api/server-api.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-28'
sections:
  introduction: 33c4ce1c59342826
  authentication: a215188bb0ae2b38
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
  provisioning: de7ad238bf914455
generated:
  introduction: 2aae3d4854ceece3
  authentication: 309f31a76c7ed969
  user-object: 9009ec1d00c571fb
  list-users: 9264d8ebac0bc28f
  example: e999176324850972
  show-user: ec4ef74fad664f43
  examples: 8198f6712632649a
  update-user: c78b91ae370b879b
  params: 2d6c9cbe5d869681
  examples-2: 4517f4dff047044d
  deactivate-user: c3f209c137d807e1
  examples-3: 807c26a1a5305414
  reactivate-user: a0747565a1d2e741
  examples-4: d448eb624aa68101
  redact-user: cd294e9eed249e7e
  examples-5: '00187fc0e296bcc6'
  delete-user: 1a2fdb797f42576a
  examples-6: beda53cef1f7c65b
  sso-profile-sync-settings: 19f51ee598df132e
  provisioning: ac3e2ef9440c8c6f
title_source: 370e81eb20eece44
title_generated: d867b511d9d6c400
---

<!-- translation-section: introduction -->

# תיעוד API השרת של Loomio

<!-- seo-description: ניתן להשתמש ב-API השרת של Loomio ליצירת חשבונות משתמשים, לאיתור קבוצות ולניהול חברויות בהתקנת Loomio באירוח עצמי. -->

`/api/server0` מיועד לפעולות ברמת השרת. לפעולות ברמת המשתמש המתבצעות באמצעות חשבון משתמש ב-Loomio, יש להשתמש ב-`/api/user0`.

ניתן להשתמש במפתח שרת אחד ליצירת חשבונות ולניהולם, לאיתור קבוצות בכל ההתקנה ולניהול החברויות והתפקידים בהן. אין צורך בחשבון בוט, במפתח API של משתמש או בחברות בקבוצות. מפתחות API של משתמשים ממשיכים להיות כפופים להרשאות המשתמש בקבוצות.

<!-- translation-section: authentication -->

## אימות

המפתח הוא הערך של ההגדרה `SERVER_API_KEY` בסביבת השרת. `create_env.sh` יוצר מפתח להתקנות חדשות.

יש לשלוח את המפתח כאסימון Bearer:

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users
```

יש לשלוח פרטי אימות רק בכותרת `Authorization`. מפתחות API במחרוזות שאילתה או בגופי בקשות נדחים.

<!-- translation-section: provisioning -->

## יצירת חשבונות וניהול חברויות

| שיטה | נקודת קצה | מטרה |
| --- | --- | --- |
| `POST` | `/api/server0/users` | יצירת חשבון |
| `GET` | `/api/server0/groups` | איתור קבוצות בכל ההתקנה |
| `GET` | `/api/server0/memberships` | הצגת רשימת חברויות בקבוצה |
| `POST` | `/api/server0/memberships` | הזמנת חברים או סנכרון רשימת חברויות מלאה |
| `PATCH` | `/api/server0/memberships/:id` | שינוי תפקידי מנהל קבוצה ונציג |
| `DELETE` | `/api/server0/memberships/:id` | ביטול חברות אחת |

נקודות הקצה לעדכון חשבון קיים, להשבתתו, להפעלתו מחדש, להסרת פרטים מזהים ממנו ולמחיקתו מתוארות בהמשך.

### יצירת חשבון

`POST /api/server0/users`

יש לשלוח אובייקט `user` עם שדה החובה `email`. רווחים בתחילת כתובות האימייל ובסופן מוסרים, והכתובות מומרות לאותיות קטנות. השדות האופציונליים הם `name`,‏ `username` ו-`is_admin`. כאן `is_admin` מציין מנהל של ההתקנה; תפקידי מנהל קבוצה מנוהלים ברשומות החברות. ליצירת שם משתמש באופן אוטומטי, יש להשמיט את `username`. שדות לא מוכרים נדחים.

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

התגובה היא HTTP `201` עם אובייקט `user`. שדות לא תקינים, כתובת אימייל שכבר נמצאת בשימוש או שם משתמש שכבר נמצא בשימוש מחזירים HTTP `422`. יצירת חשבון אינה שולחת הזמנה, אינה מבצעת כניסה לחשבון ואינה מסמנת את כתובת האימייל כמאומתת. לשליחת הזמנה בתהליך ההתראות הרגיל, יש להזמין לקבוצה באמצעות נקודת הקצה לניהול חברויות.

### איתור קבוצות

`GET /api/server0/groups`

הצגת רשימת כל הקבוצות שלא נמחקו, כולל קבוצות פרטיות וקבוצות שתוקף המינוי שלהן פג. התוצאות מסודרות לפי מזהה בסדר עולה. למעבר בין עמודי התוצאות, יש להשתמש ב-`limit` (ברירת המחדל והערך המרבי הם `50`) וב-`offset` (ברירת המחדל היא `0`).

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

### הצגת רשימת חברויות

`GET /api/server0/memberships?group_id=123`

`group_id` הוא שדה חובה. התוצאות כוללות חברויות שאושרו והזמנות ממתינות, ומסודרות לפי מזהה החברות בסדר עולה. חברויות שבוטלו אינן נכללות. לחלוקה לעמודים, יש להשתמש ב-`limit` (ברירת המחדל והערך המרבי הם `50`) וב-`offset` (ברירת המחדל היא `0`).

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

`admin` ו-`delegate` הם תפקידים בקבוצה. `accepted_at` הוא חותמת הזמן של אישור ההזמנה, או `null` כל עוד ההזמנה ממתינה. נקודת קצה זו אינה חושפת אסימוני הזמנה, פרטי כניסה או הצבעות.

### הזמנת חברים או סנכרונם

`POST /api/server0/memberships`

יש לשלוח את שדה החובה `group_id` ואת המערך `emails`. כברירת מחדל, הפעולה מוסיפה את האנשים ברשימה שאין להם חברות פעילה, ומשאירה את כל השאר ללא שינוי. רווחים בתחילת כתובות האימייל ובסופן מוסרים, הכתובות מומרות לאותיות קטנות וכפילויות מוסרות. עבור כתובות חדשות נוצרים חשבונות והזמנות ממתינות. חברים קיימים ומאומתים בקבוצה פעילה אחרת באותו ארגון מתקבלים אוטומטית, בהתאם לתהליך ההזמנה ב-API המשתמש.

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

לסנכרון רשימת חברויות מלאה, יש להגדיר במפורש את `remove_absent` לערך `true`. כל מי שאינו ברשימה מוסר מהקבוצה ומתת־הקבוצות שלה. מערך ריק עם `remove_absent: true` מסיר את כולם, כולל מנהלי הקבוצה. בעת הוספת אנשים בלבד, יש להשמיט את `remove_absent` או להגדיר אותו לערך `false`. גם הערכים הישנים `1` ו-`0` מתקבלים.

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

שליחה חוזרת של אותה בקשה אינה יוצרת חברויות כפולות ואינה שולחת הזמנות חוזרות. הזמנה מחדש של חבר שחברותו בוטלה משחזרת את הגישה לקבוצה בלי לשחזר תפקיד מנהל קודם. הזמנות חדשות ושינויי תפקידים משתמשים בתהליך ההתראות הרגיל, ללא רישום משתמש כמי שביצע את הפעולה.

רשימות אימייל חסרות או בעלות מבנה לא תקין וערכים בוליאניים לא תקינים מחזירים HTTP `400`. חשבון מושבת שמופיע ברשימה מחזיר HTTP `422`; יש להפעילו מחדש במפורש לפני הוספתו. נתוני חשבון לא תקינים, מגבלות מינוי או כשלים אחרים מבטלים את כל שינויי הסנכרון, כולל חשבונות חדשים והסרות של חברויות. הוספת חברים דורשת קבוצה פעילה וכפופה למגבלות מספר החברים במינוי.

### עדכון תפקידי חברות

`PATCH /api/server0/memberships/:id`

יש לשלוח אובייקט `membership` המכיל אחד מהשדות הבוליאניים `admin` ו-`delegate` או את שניהם. תפקידים שהושמטו נשארים ללא שינוי. שדות לא מוכרים נדחים; נקודת הקצה אינה מאפשרת להעביר חברות, לאשר הזמנה או לשנות משקלי הצבעה.

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

מוחזר אובייקט `membership` עם אותם שדות כמו ברשומת חברות ברשימה. הענקת תפקיד יוצרת את התראת התפקיד הרגילה; שליחה חוזרת של תפקיד שלא השתנה אינה שולחת התראה נוספת. שינויי תפקידים דורשים קבוצה פעילה. חברויות שבוטלו מחזירות HTTP `404`.

### הסרת חברות אחת

`DELETE /api/server0/memberships/:id`

```bash
curl https://loomio.example.org/api/server0/memberships/456 \
  -X DELETE \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY'
```

מוחזר `{"success": true}`. ההסרה מבטלת את הגישה לקבוצה ולתת־הקבוצות שלה, כולל גישה לנושאים וזכויות הצבעה בסקרים פעילים. היא אינה מוחקת את החשבון, משנה קבוצות שאינן קשורות או מסירה גישה ישירה לשרשורים. הסרה חוזרת מסתיימת בהצלחה. ניתן להסיר חברויות מקבוצות שתוקף המינוי שלהן פג; קבוצות שנמחקו מחזירות HTTP `404`.

<!-- translation-section: user-object -->

## אובייקט משתמש

תגובות המכילות נתוני משתמש הן במבנה הבא:

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

## רשימת משתמשים

ניתן לקבל רשימה של כל חשבונות המשתמשים בהתקנת Loomio.

`GET /api/server0/users`

<!-- translation-section: example -->

### דוגמה

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users
```

התגובה:

```json
{
  "users": []
}
```

<!-- translation-section: show-user -->

## הצגת משתמש

ניתן לאתר חשבון משתמש לפי מזהה המשתמש ב-Loomio או לפי זהות חיצונית.

`GET /api/server0/users/:id`

`GET /api/server0/users/identity/:identity_type/:uid`

<!-- translation-section: examples -->

### דוגמאות

לפי מזהה המשתמש ב-Loomio:

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/123
```

לפי זהות חיצונית:

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/identity/oauth/external-123
```

התגובה:

```json
{
  "user": {}
}
```

<!-- translation-section: update-user -->

## עדכון משתמש

ניתן לעדכן את שדות הפרופיל של חשבון משתמש שאותר לפי מזהה המשתמש ב-Loomio או לפי זהות חיצונית.

`PATCH /api/server0/users/:id`

`PATCH /api/server0/users/identity/:identity_type/:uid`

<!-- translation-section: params -->

### פרמטרים

| שדה | תיאור |
| --- | --- |
| `name` | שם לתצוגה |
| `username` | שם משתמש ב-Loomio |
| `email` | כתובת דוא״ל |

<!-- translation-section: examples-2 -->

### דוגמאות

לפי מזהה המשתמש ב-Loomio:

```bash
curl -X PATCH \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"user":{"name":"Ada Lovelace","username":"ada","email":"ada@example.org"}}' \
  https://www.loomio.com/api/server0/users/123
```

לפי זהות חיצונית:

```bash
curl -X PATCH \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"user":{"name":"Ada Lovelace","username":"ada","email":"ada@example.org"}}' \
  https://www.loomio.com/api/server0/users/identity/oauth/external-123
```

התגובה מכילה את נתוני המשתמש המעודכנים:

```json
{
  "user": {}
}
```

<!-- translation-section: deactivate-user -->

## השבתת משתמש

ניתן להשבית חשבון משתמש שאותר לפי מזהה המשתמש ב-Loomio או לפי זהות חיצונית.

`POST /api/server0/users/:id/deactivate`

`POST /api/server0/users/identity/:identity_type/:uid/deactivate`

<!-- translation-section: examples-3 -->

### דוגמאות

לפי מזהה המשתמש ב-Loomio:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/123/deactivate
```

לפי זהות חיצונית:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/identity/oauth/external-123/deactivate
```

התגובה:

```json
{
  "success": true,
  "user": {}
}
```

<!-- translation-section: reactivate-user -->

## הפעלה מחדש של חשבון

ניתן להפעיל מחדש חשבון מושבת באמצעות מזהה החשבון ב־Loomio או זהות חיצונית.

`POST /api/server0/users/:id/reactivate`

`POST /api/server0/users/identity/:identity_type/:uid/reactivate`

<!-- translation-section: examples-4 -->

### דוגמאות

לפי מזהה החשבון ב־Loomio:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/123/reactivate
```

לפי זהות חיצונית:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/identity/oauth/external-123/reactivate
```

התשובה המוחזרת:

```json
{
  "success": true,
  "user": {}
}
```

<!-- translation-section: redact-user -->

## הסרת פרטים מזהים מחשבון

הסרת פרטים מזהים משאירה בקבוצות את התגובות ואת התוכן האחר שנוצר באמצעות החשבון, אך מסירה מידע אישי מזהה ידוע כגון שם, תיאור אישי, תמונת פרופיל, כתובת דוא״ל, פרטי התחברות, זהויות והפעלות פעילות.

זו הדרך המומלצת להסרת חשבון מ־Loomio.

`POST /api/server0/users/:id/redact`

`POST /api/server0/users/identity/:identity_type/:uid/redact`

<!-- translation-section: examples-5 -->

### דוגמאות

לפי מזהה החשבון ב־Loomio:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/123/redact
```

לפי זהות חיצונית:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/identity/oauth/external-123/redact
```

התשובה המוחזרת:

```json
{
  "success": true
}
```

<!-- translation-section: delete-user -->

## מחיקת חשבון

מחיקה מסירה את החשבון ואת הרשומות שנוצרו באמצעותו. תגובות מוסרות משרשורים, הצבעות מוסרות מסקרים, וגם קבוצות, דיונים, סקרים ורשומות אחרות שנוצרו באמצעות החשבון עשויים להימחק עקב קשרים בין רשומות במסד הנתונים.

פעולה זו גורמת למחיקה נרחבת של נתונים. מומלץ מאוד להסיר פרטים מזהים במקום זאת.

`DELETE /api/server0/users/:id`

`DELETE /api/server0/users/identity/:identity_type/:uid`

<!-- translation-section: examples-6 -->

### דוגמאות

לפי מזהה החשבון ב־Loomio:

```bash
curl -X DELETE -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/123
```

לפי זהות חיצונית:

```bash
curl -X DELETE -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/identity/oauth/external-123
```

התשובה המוחזרת:

```json
{
  "success": true
}
```

<!-- translation-section: sso-profile-sync-settings -->

## הגדרות סנכרון פרופיל באמצעות SSO

יש להשתמש בהגדרות אלה כאשר מערכת אחרת מנהלת את שדות הפרופיל ב־Loomio.

```env
LOOMIO_DISABLE_EDIT_USER_PROFILE=1
# LOOMIO_SSO_UPDATE_USER_PROFILE_ON_LOGIN=1
```

`LOOMIO_DISABLE_EDIT_USER_PROFILE=1` מונע עריכה עצמאית של השדות הבאים:

| שדה | הערות |
| --- | --- |
| `name` | מנוהל באמצעות סנכרון חיצוני |
| `username` | מנוהל באמצעות סנכרון חיצוני |
| `email` | מנוהל באמצעות סנכרון חיצוני |
| `avatar_kind` / `uploaded_avatar` | מנוהל באמצעות סנכרון חיצוני |

עדיין ניתן לערוך שדות מקומיים של Loomio כגון `short_bio` ו־`location`.

`LOOMIO_SSO_UPDATE_USER_PROFILE_ON_LOGIN=1` מעדכן את `name` ואת `email` מתוך נתוני ההתחברות באמצעות SSO. יש להשאיר שורה זו כהערה או לא להגדיר את המשתנה כאשר סקריפט סנכרון חיצוני אמור להיות המקור היחיד לעדכונים אלה.

`LOOMIO_SSO_FORCE_USER_ATTRS` ממשיך לפעול בהתקנות קיימות. הוא גם מונע עריכה עצמאית וגם מעדכן את `name` ואת `email` בעת התחברות באמצעות SSO.
