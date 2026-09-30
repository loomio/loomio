---
title: API השרת
source_revision: 7a01b0fd7d7df0c4bca327a916b01b12e62b967f
source_file: docs/user_manual/integrations/api/server-api.md
translated:
  provider: codex/gpt-6-sol
  'on': '2026-09-30'
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
  introduction: e1f9f4ffb344c755
  authentication: 4497b1d2a25e2c1a
  user-object: 671ba8274d284640
  list-users: 8088eded1df2ff0c
  example: 4c14e04f9c696c67
  show-user: 91e2d7393bd094a9
  examples: 8087247827e7e159
  update-user: f5085577d4230958
  params: b03c601bbde002d8
  examples-2: 9f567d7d8e96c75f
  deactivate-user: 7dfe5cd70c7b3db4
  examples-3: f465524c7dea89de
  reactivate-user: bc82714fc5fc823d
  examples-4: 4e0c43e30520097d
  redact-user: 394fdea16b70fbca
  examples-5: 92f95cbe6a545ca8
  delete-user: b9247dab36d2dcc2
  examples-6: '08c3d1e1ba9cdb1a'
  sso-profile-sync-settings: 2285697531d0c061
title_source: 370e81eb20eece44
title_generated: d867b511d9d6c400
---

<!-- translation-section: introduction -->

# תיעוד API השרת של Loomio

<!-- seo-description: ניתן להשתמש ב-API השרת של Loomio לניהול חשבונות משתמשים בהתקנת Loomio באירוח עצמי. -->

`/api/b3` מיועד לפעולות ברמת השרת. לפעולות המתבצעות באמצעות חשבון משתמש של Loomio, יש להשתמש ב-`/api/b2`.

<!-- translation-section: authentication -->

## אימות

יש להגדיר את `B3_API_KEY` לערך סודי שאורכו יותר מ-16 תווים.

יש לשלוח את המפתח כאסימון Bearer:

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users
```

יש לשלוח פרטי אימות רק בכותרת `Authorization`. מפתחות API שנשלחים בפרמטרים של כתובת הבקשה או בגוף הבקשה נדחים.

<!-- translation-section: user-object -->

## אובייקט משתמש

תגובות הכוללות משתמש הן במבנה הבא:

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

הצגת כל חשבונות המשתמשים בהתקנת Loomio.

`GET /api/b3/users`

<!-- translation-section: example -->

### דוגמה

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users
```

מוחזר:

```json
{
  "users": []
}
```

<!-- translation-section: show-user -->

## הצגת משתמש

איתור משתמש לפי מזהה המשתמש ב-Loomio או לפי זהות חיצונית.

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

מוחזר:

```json
{
  "user": {}
}
```

<!-- translation-section: update-user -->

## עדכון משתמש

עדכון שדות הפרופיל של משתמש שאותר לפי מזהה המשתמש ב-Loomio או לפי זהות חיצונית.

`PATCH /api/b3/users/:id`

`PATCH /api/b3/users/identity/:identity_type/:uid`

<!-- translation-section: params -->

### פרמטרים

| שדה | תיאור |
| --- | --- |
| `name` | שם תצוגה |
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

פרטי המשתמש המעודכנים מוחזרים:

```json
{
  "user": {}
}
```

<!-- translation-section: deactivate-user -->

## השבתת משתמש

השבתת חשבון משתמש לפי מזהה המשתמש ב-Loomio או לפי זהות חיצונית.

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

מוחזר:

```json
{
  "success": true,
  "user": {}
}
```

<!-- translation-section: reactivate-user -->

## הפעלה מחדש של משתמש

הפעלה מחדש של חשבון משתמש שהושבת, לפי מזהה המשתמש ב-Loomio או לפי זהות חיצונית.

`POST /api/b3/users/:id/reactivate`

`POST /api/b3/users/identity/:identity_type/:uid/reactivate`

<!-- translation-section: examples-4 -->

### דוגמאות

לפי מזהה המשתמש ב-Loomio:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123/reactivate
```

לפי זהות חיצונית:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/identity/oauth/external-123/reactivate
```

מוחזר:

```json
{
  "success": true,
  "user": {}
}
```

<!-- translation-section: redact-user -->

## הסרת פרטים מזהים של משתמש

הסרת פרטים מזהים משאירה בקבוצות את התגובות ותכנים אחרים שיצר המשתמש, אך מסירה מידע אישי מזהה ידוע, כגון שם, ביוגרפיה, תמונת פרופיל, כתובת דוא״ל, פרטי התחברות, זהויות והפעלות פעילות.

זו הדרך המומלצת להסיר משתמש מ-Loomio.

`POST /api/b3/users/:id/redact`

`POST /api/b3/users/identity/:identity_type/:uid/redact`

<!-- translation-section: examples-5 -->

### דוגמאות

לפי מזהה המשתמש ב-Loomio:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123/redact
```

לפי זהות חיצונית:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/identity/oauth/external-123/redact
```

מוחזר:

```json
{
  "success": true
}
```

<!-- translation-section: delete-user -->

## מחיקת משתמש

מחיקה מסירה את המשתמש ואת הרשומות שיצר. תגובות מוסרות משרשורים והצבעות מוסרות מסקרים. קשרים בין רשומות במסד הנתונים עשויים לגרום למחיקה גם של קבוצות, דיונים, סקרים ורשומות אחרות שיצר המשתמש.

פעולה זו מוחקת מידע רב. מומלץ מאוד להסיר פרטים מזהים במקום זאת.

`DELETE /api/b3/users/:id`

`DELETE /api/b3/users/identity/:identity_type/:uid`

<!-- translation-section: examples-6 -->

### דוגמאות

לפי מזהה המשתמש ב-Loomio:

```bash
curl -X DELETE -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123
```

לפי זהות חיצונית:

```bash
curl -X DELETE -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/identity/oauth/external-123
```

מוחזר:

```json
{
  "success": true
}
```

<!-- translation-section: sso-profile-sync-settings -->

## הגדרות לסנכרון פרופיל באמצעות SSO

יש להשתמש בהגדרות אלה כאשר מערכת אחרת מנהלת את שדות הפרופיל ב־Loomio.

```env
LOOMIO_DISABLE_EDIT_USER_PROFILE=1
# LOOMIO_SSO_UPDATE_USER_PROFILE_ON_LOGIN=1
```

`LOOMIO_DISABLE_EDIT_USER_PROFILE=1` מונע ממשתמשים לערוך בעצמם את השדות האלה:

| שדה | הערות |
| --- | --- |
| `name` | מנוהל באמצעות סנכרון חיצוני |
| `username` | מנוהל באמצעות סנכרון חיצוני |
| `email` | מנוהל באמצעות סנכרון חיצוני |
| `avatar_kind` / `uploaded_avatar` | מנוהל באמצעות סנכרון חיצוני |

עדיין ניתן לערוך שדות מקומיים של Loomio, כגון `short_bio` ו־`location`.

`LOOMIO_SSO_UPDATE_USER_PROFILE_ON_LOGIN=1` מעדכן את `name` ואת `email` לפי נתוני ההתחברות באמצעות SSO. אם סקריפט סנכרון חיצוני אמור להיות המקור היחיד לעדכונים אלה, יש להשאיר את השורה כהערה או לא להגדיר את המשתנה.

`LOOMIO_SSO_FORCE_USER_ATTRS` ממשיך לפעול בהתקנות קיימות. הוא מונע ממשתמשים לערוך את שדות הפרופיל, ומעדכן את `name` ואת `email` בעת התחברות באמצעות SSO.
