---
title: API
source_revision: 924e704b41670a012a16528cf88edf90f8d6b572
source_file: docs/en/user_manual/integrations/api/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-01'
sections:
  introduction: 99e59473b33baba1
  user-api: 8424224e38edf17f
  server-api: f1bf07c1162ff08b
generated:
  introduction: b6dc083f4409e997
  user-api: f746cd40d4279938
  server-api: 2dc9cd10c89530f4
title_source: c8e5998f6a3955c2
title_generated: c8e5998f6a3955c2
---

<!-- translation-section: introduction -->

# ה־API של Loomio

ניתן להשתמש ב־API של Loomio כדי לחבר את Loomio לתוכנות אחרות ולתהליכי עבודה אוטומטיים.

[מפרט OpenAPI 3.1](openapi.yaml) מתאר כל פעולה ציבורית ב־API למשתמשים וב־API לשרת בפורמט קריא למכונה. ניתן לייבא אותו לכלי לקוח API או להשתמש בו כדי ליצור קוד לקוח עם טיפוסים מוגדרים. המדריכים שלהלן מסבירים תהליכי עבודה, הרשאות והתנהגות שאינם מתוארים במלואם במפרט.

<!-- translation-section: user-api -->

## API למשתמשים

[ה־API למשתמשים](/en/user_manual/integrations/api/user-api) מבצע פעולות בשם חשבון משתמש ב־Loomio. ניתן באמצעותו להציג רשימת קבוצות וליצור או לנהל שרשורים, תגובות, סקרים וחברויות בקבוצות, בהתאם להרשאות של אותו חשבון.

לשילובים המבוססים על דחיפת מידע, [webhooks של קבוצות](/en/user_manual/integrations/api/user-api#webhooks) שולחים אירועים נבחרים מ־Loomio לנקודת קצה באינטרנט בפורמט JSON. יש להשתמש בנקודות הקצה של REST כדי לקרוא או לשנות נתונים ב־Loomio, וב־webhook כאשר השילוב צריך לקבל אירועים ללא בדיקות חוזרות.

<!-- translation-section: server-api -->

## API לשרת

[ה־API לשרת](/en/user_manual/integrations/api/server-api) מאפשר לנהל חשבונות משתמשים בהתקנות Loomio באירוח עצמי. האימות מתבצע באמצעות סוד משותף לכל השרת.
