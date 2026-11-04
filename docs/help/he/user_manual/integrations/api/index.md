---
title: API
source_revision: 2d360988a87765e6a1345dd06155bc988154178e
source_file: docs/help/en/user_manual/integrations/api/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-23'
sections:
  introduction: 99e59473b33baba1
  user-api: 8424224e38edf17f
  server-api: 42859c6715b7a994
generated:
  introduction: b6dc083f4409e997
  user-api: f746cd40d4279938
  server-api: 89d67d159e85f503
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

[ה־API לשרת](/en/user_manual/integrations/api/server-api) מאפשר לתפעל התקנות Loomio באירוח עצמי: ליצור ולנהל חשבונות משתמשים, לאתר קבוצות ולנהל חברוּת בקבוצות ותפקידים. האימות מתבצע באמצעות סוד משותף לכל השרת, ואין צורך בחשבון בוט או בחברוּת בכל קבוצה.
