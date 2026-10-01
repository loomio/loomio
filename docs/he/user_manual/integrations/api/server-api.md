---
title: API השרת
source_revision: 924e704b41670a012a16528cf88edf90f8d6b572
source_file: docs/en/user_manual/integrations/api/server-api.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-01'
sections:
  introduction: a357cdc2bfc0223e
  authentication: cbabcc874f053455
  user-object: c3a00ec4e3d66b09
  list-users: c7d62eee05e7a6a4
  example: 2f817ab1533206e6
  show-user: 36fa596a6a5c2fd8
  examples: 522d17246020d82f
  update-user: 39d632ce15d489d3
  params: 368f797e2a2b5c3d
  examples-2: 3aab846e77253829
  deactivate-user: 132d435583a46920
  examples-3: d8c7c152ab2b0ace
  reactivate-user: 309592dead978456
  examples-4: 95251484d1fd7e1d
  redact-user: 47ea30122aa92fae
  examples-5: 9d3bb1c3a865f3e0
  delete-user: 2d5a1dbd23324e6f
  examples-6: 71ae30577730b261
  sso-profile-sync-settings: 416144004d040e4f
generated:
  introduction: bc372ece08ee1602
  authentication: 3d86e75800069482
  user-object: 4cc1839c9ea2488e
  list-users: 57ef409f012e8403
  example: 3b6f31c888966421
  show-user: 11e709ab30355d5e
  examples: 68b3e7c30709b272
  update-user: 9fe9f1bf6714635e
  params: 2d6c9cbe5d869681
  examples-2: f6b02fc05e03ead2
  deactivate-user: e4ae5d2b7c11dd6f
  examples-3: 61339975c5e4ef63
  reactivate-user: 25cbd4320128a1c1
  examples-4: 17539b5a5093cf95
  redact-user: 42f20e1d21671c38
  examples-5: 266eff02ce099a0c
  delete-user: e858ac01dfb8bfda
  examples-6: b231fb99e7bec705
  sso-profile-sync-settings: 19f51ee598df132e
title_source: 370e81eb20eece44
title_generated: d867b511d9d6c400
---

<!-- translation-section: introduction -->

# תיעוד API השרת של Loomio

<!-- seo-description: ניתן להשתמש ב-API השרת של Loomio לניהול חשבונות משתמשים בהתקנת Loomio באירוח עצמי. -->

`/api/b3` מיועד לפעולות ברמת השרת. לפעולות ברמת המשתמש המתבצעות באמצעות חשבון משתמש ב-Loomio, יש להשתמש ב-`/api/b2`.

<!-- translation-section: authentication -->

## אימות

יש להגדיר את `B3_API_KEY` לערך סודי שאורכו יותר מ-16 תווים.

יש לשלוח את המפתח כאסימון Bearer:

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users
```

יש לשלוח פרטי אימות רק בכותרת `Authorization`. מפתחות API במחרוזות שאילתה או בגופי בקשות נדחים.

<!-- translation-section: user-object -->

## אובייקט משתמש

תגובות המכילות נתוני משתמש הן במבנה הבא:

```json
{
  "id": 123,
  "name": "Ada Lovelace",
  "username": "ada",
  "email": "ada@example.org",
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

`GET /api/b3/users`

<!-- translation-section: example -->

### דוגמה

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users
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

`GET /api/b3/users/:id`

`GET /api/b3/users/identity/:identity_type/:uid`

<!-- translation-section: examples -->

### דוגמאות

לפי מזהה המשתמש ב-Loomio:

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123
```

לפי זהות חיצונית:

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/identity/oauth/external-123
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

`PATCH /api/b3/users/:id`

`PATCH /api/b3/users/identity/:identity_type/:uid`

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
  https://www.loomio.com/api/b3/users/123
```

לפי זהות חיצונית:

```bash
curl -X PATCH \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"user":{"name":"Ada Lovelace","username":"ada","email":"ada@example.org"}}' \
  https://www.loomio.com/api/b3/users/identity/oauth/external-123
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

`POST /api/b3/users/:id/deactivate`

`POST /api/b3/users/identity/:identity_type/:uid/deactivate`

<!-- translation-section: examples-3 -->

### דוגמאות

לפי מזהה המשתמש ב-Loomio:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123/deactivate
```

לפי זהות חיצונית:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/identity/oauth/external-123/deactivate
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

`POST /api/b3/users/:id/reactivate`

`POST /api/b3/users/identity/:identity_type/:uid/reactivate`

<!-- translation-section: examples-4 -->

### דוגמאות

לפי מזהה החשבון ב־Loomio:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123/reactivate
```

לפי זהות חיצונית:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/identity/oauth/external-123/reactivate
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

`POST /api/b3/users/:id/redact`

`POST /api/b3/users/identity/:identity_type/:uid/redact`

<!-- translation-section: examples-5 -->

### דוגמאות

לפי מזהה החשבון ב־Loomio:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123/redact
```

לפי זהות חיצונית:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/identity/oauth/external-123/redact
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

`DELETE /api/b3/users/:id`

`DELETE /api/b3/users/identity/:identity_type/:uid`

<!-- translation-section: examples-6 -->

### דוגמאות

לפי מזהה החשבון ב־Loomio:

```bash
curl -X DELETE -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123
```

לפי זהות חיצונית:

```bash
curl -X DELETE -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/identity/oauth/external-123
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
