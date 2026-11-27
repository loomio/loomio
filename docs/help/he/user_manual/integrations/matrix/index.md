---
title: Matrix
source_revision: 6e7aad6a91a50e55dca43a20edcc88d445ee4185
source_file: docs/help/en/user_manual/integrations/matrix/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-11-26'
sections:
  introduction: 31651f229b065ec2
generated:
  introduction: e7abdf509d830cb2
title_source: 76a2171c057b730f
title_generated: 76a2171c057b730f
needs_review:
  introduction: check the interface label "**אסימון גישה**" for "**Access Token**"
---

<!-- translation-section: introduction -->

# שילוב עם Matrix

Loomio יכולה לשלוח התראות לחדר ב-Matrix כאשר נוצרים דיונים, סקרים, תגובות, הצבעות ומסקנות. הוספת שילוב צ׳אט מחייבת הרשאת מנהל קבוצה.

בשונה משילובי הצ׳אט האחרים של Loomio, השילוב עם Matrix אינו משתמש ב-webhook. Loomio מתחברת באמצעות חשבון משתמש ב-Matrix שפועל כבוט ומפרסם הודעות מעוצבות בחדר.

במדריך זה נעשה שימוש בלקוח Element.

---

1. יש ליצור חשבון משתמש ב-Matrix עבור Loomio, להתחבר אליו ב-Element ולהזמין אותו לחדר ב-Matrix שבו יוצגו ההתראות. יש להשאיר את החשבון מחובר — התנתקות מבטלת את תוקף אסימון הגישה.

2. בקבוצה ב-Loomio, יש לפתוח את **הגדרות**, לבחור **אינטגרציות צ'אט** ולהוסיף שילוב צ׳אט מסוג **מַטרִיצָה**.

   ![תפריט הוספת בוט Matrix ב-Loomio](loomio-add-matrix-bot.png)

   ![טופס בוט Matrix ב-Loomio](loomio-matrix-bot-form.png)

3. ב-Element, יש לפתוח את תפריט חשבון הבוט ולבחור **כל ההגדרות**.

   ![תפריט ההגדרות של Matrix](matrix-settings-menu.png)

4. יש לפתוח את **עזרה ואודות** ולגלול לסעיף **מתקדם**.

   ![הגדרות Matrix](matrix-settings.png)

5. יש להעתיק את **אסימון הגישה** ולהדביק אותו בטופס ב-Loomio.

   ![אסימון הגישה של Matrix](matrix-access-token.png)

6. יש לפתוח את תפריט **הגדרות** של החדר ולעבור אל **מתקדם**.

   ![הגדרות החדר ב-Matrix](matrix-room-settings.png)

7. יש להעתיק את **מזהה החדר הפנימי**, להדביק אותו בטופס ב-Loomio ולשמור את השילוב.

   ![מזהה החדר ב-Matrix](matrix-room-id.png)
