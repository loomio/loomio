---
title: API
source_revision: 7a01b0fd7d7df0c4bca327a916b01b12e62b967f
source_file: docs/user_manual/integrations/api/index.md
translated:
  provider: codex/gpt-6-sol
  'on': '2026-09-30'
sections:
  introduction: 99e59473b33baba1
  user-api: 8424224e38edf17f
  server-api: f1bf07c1162ff08b
generated:
  introduction: b2b05fcecbd78fb3
  user-api: 0b403625317f090a
  server-api: c0d7ea660bb56b29
title_source: c8e5998f6a3955c2
title_generated: c8e5998f6a3955c2
---

<!-- translation-section: introduction -->

# ה-API של Loomio

ניתן להשתמש ב-API של Loomio כדי לחבר את Loomio לתוכנות אחרות ולתהליכי עבודה אוטומטיים.

[מפרט OpenAPI 3.1](openapi.yaml) מתאר בפורמט קריא למכונה את כל הפעולות הציבוריות של API המשתמשים ושל API השרת. ניתן לייבא אותו ללקוח API או להשתמש בו כדי ליצור קוד לקוח עם טיפוסים מוגדרים. המדריכים שלהלן מסבירים תהליכי עבודה, הרשאות והתנהגות שהמפרט אינו מתאר במלואם.

<!-- translation-section: user-api -->

## API המשתמשים

[API המשתמשים](/en/user_manual/integrations/api/user-api) מאפשר לבצע פעולות בשם משתמשי Loomio. באמצעותו ניתן להציג רשימת קבוצות וליצור או לנהל דיונים, תגובות, סקרים וחברויות בקבוצות, בהתאם להרשאות המשתמשים.

בשילובים המבוססים על שליחת אירועים, [webhooks של קבוצות](/en/user_manual/integrations/api/user-api#webhooks) שולחים אירועים נבחרים מ-Loomio לנקודת קצה באינטרנט בפורמט JSON. ניתן להשתמש בנקודות הקצה של REST כדי לקרוא או לשנות נתונים ב-Loomio, וב-webhook כדי לקבל אירועים בלי לבצע בדיקות חוזרות.

<!-- translation-section: server-api -->

## API השרת

[API השרת](/en/user_manual/integrations/api/server-api) מאפשר למפעילי התקנות Loomio באירוח עצמי לנהל חשבונות משתמשים. האימות מתבצע באמצעות סוד התקף לכל השרת.
