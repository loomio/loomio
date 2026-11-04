---
title: Matrix
source_revision: 924e704b41670a012a16528cf88edf90f8d6b572
source_file: docs/en/user_manual/integrations/matrix/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-01'
sections:
  introduction: e54de0b6d9ea9ffb
generated:
  introduction: 371571ac957e3428
title_source: 76a2171c057b730f
title_generated: 76a2171c057b730f
---

<!-- translation-section: introduction -->

# שילוב עם Matrix

Loomio יכולה לשלוח התראות לערוצי Matrix כאשר נוצרים דיונים, הצעות, תגובות, הצבעות ומסקנות.

Matrix מאפשרת להשתמש בחלק מתגי HTML בחדר הצ׳אט, ו-Loomio משתמשת באפשרות זו.

השילוב עם Matrix שונה מעט משילובי הצ׳אט האחרים שלנו: הוא אינו משתמש ב-webhook, אלא בלקוח בוט ייעודי שפיתחנו עבורו.

יש ליצור חשבון משתמש ב-Matrix שבאמצעותו הבוט יתחבר.

לאחר יצירת חשבון המשתמש עבור הבוט, יש להתחבר באמצעותו כדי לקבל את הפרטים הבאים.

במדריך זה נעשה שימוש ב-Element.

---

מתוך הקבוצה ב-Loomio, יש להוסיף שילוב צ׳אט עם Matrix
![תפריט הוספת בוט Matrix ב-Loomio](loomio-add-matrix-bot.png)

זהו הטופס שיש למלא
![טופס בוט Matrix ב-Loomio](loomio-matrix-bot-form.png)

כאן מתחילים בחיפוש אסימון הגישה
![תפריט ההגדרות של Matrix](matrix-settings-menu.png)

זהו עמוד ההגדרות
![הגדרות Matrix](matrix-settings.png)

זהו אסימון הגישה עצמו
![אסימון הגישה של Matrix](matrix-access-token.png)

כעת יש למצוא את מזהה החדר
![הגדרות החדר ב-Matrix](matrix-room-settings.png)

כאן מופיע מזהה החדר.
![מזהה החדר ב-Matrix](matrix-room-id.png)
