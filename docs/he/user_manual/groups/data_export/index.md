---
title: ייצוא נתונים
source_revision: 7a01b0fd7d7df0c4bca327a916b01b12e62b967f
source_file: docs/user_manual/groups/data_export/index.md
translated:
  provider: codex/gpt-6-sol
  'on': '2026-09-29'
sections:
  introduction: 5e29f67f9a2084ec
  export-data: 58b5e1d4e6f0b917
  export-group-data-as-csv: 53286ec33e7300d6
  export-group-data-as-html: 101671937dcd6f36
  export-group-data-as-json: 4ec883363fb166ee
  print-thread-to-pdf: 39c48383953f9fd5
  import-your-group-data-on-another-loomio-server: 910ee8af48049e82
generated:
  introduction: 983949acf2cc29b6
  export-data: 026dec0c978a2f8f
  export-group-data-as-csv: 2e887554f4b49751
  export-group-data-as-html: a1099937c0786d7c
  export-group-data-as-json: 60f9203b5cbaad6f
  print-thread-to-pdf: fca058adffe6eb4c
  import-your-group-data-on-another-loomio-server: 7f19dadd75144862
title_source: 29049648f87b87f5
title_generated: 5a4d0da747307b8b
---

<!-- translation-section: introduction -->

# גיבוי או ייצוא של נתוני קבוצה

באמצעות ייצוא נתוני קבוצה ניתן:

- להוריד קובץ עם נתוני חברי הקבוצה כדי לבדוק את רשימת החברים.
- להוריד את תוכן הקבוצה, כולל טקסט של שרשורים ומשאלים, לצורך ארכוב או ניתוח.
- לפתוח תוצאות של משאל בגיליון אלקטרוני או בשפת תכנות.
- [להדפיס שרשור או משאל או לשמור אותם כ־PDF לצורך ארכוב.](#print-thread-to-pdf)
- להעביר את הקבוצה, כולל כל המשתמשים, השרשורים, המשאלים והקבצים, לשרת Loomio אחר.

אם רוצים לעבור משרתים המנוהלים בידי Loomio [לשרת משלכם](https://github.com/loomio/loomio), ניתן להשתמש באפשרות זו.

אם הקבוצה פועלת בשרת Loomio משלכם וברצונכם לעבור לאירוח מנוהל, Loomio מציעה אירוח בארצות הברית, באיחוד האירופי ובאוסטרליה. כדי להעביר את הקבוצה לאחד השרתים האלה, יש [ליצור איתנו קשר](/contact).

כדי להעביר קבוצה משירות האירוח העולמי של Loomio ב־loomio.com לאחד השירותים האזוריים שלנו, יש [ליצור איתנו קשר](/contact). השירותים האזוריים הם loomio.eu לאירופה ו־loomio.nz לאוסטרליה ולניו זילנד.

<!-- translation-section: export-data -->

## ייצוא נתונים

יש לפתוח את התפריט הנפתח של הקבוצה בלחיצה על שלוש הנקודות ולבחור **יצוא נתונים מהקבוצה**.

![הפעולה יצוא נתונים מהקבוצה בתפריט של קואופרטיב Oatmilk](group_export_group_data.png)

<!-- translation-section: export-group-data-as-csv -->

### ייצוא נתוני קבוצה כ־CSV

*לעבודה עם נתוני הקבוצה בגיליון אלקטרוני, למשל ב־MS Excel או ב־Google Sheets.*

Loomio מכינה את קובץ ה־CSV ברקע ושולחת בדוא״ל קישור להורדה כשהקובץ מוכן. הקישור זמין למשך שבוע.

<!-- translation-section: export-group-data-as-html -->

### ייצוא נתוני קבוצה כ־HTML

*לשמירת הנתונים בארכיון.*

Loomio מכינה את קובץ ה־HTML ברקע ושולחת בדוא״ל קישור להורדה כשהקובץ מוכן. הקישור זמין למשך שבוע.

<!-- translation-section: export-group-data-as-json -->

### ייצוא נתוני קבוצה כ־JSON

*להעברת נתוני הקבוצה להתקנת Loomio באירוח עצמי.*

ייצוא הקבוצה מחייב הרשאת ניהול בקבוצה. קובץ ה־JSON המיוצא כולל:

- את הקבוצה, חבריה ובקשות ההצטרפות אליה
- שרשורים, תגובות, תגובות רגשיות, תגיות, תבניות, התראות ורשומות קשורות מהקבוצות הכלולות בייצוא
- משאלים, אפשרויות, הצבעות ומסקנות; משאל אנונימי נכלל רק לאחר שנסגר
- תת־קבוצות שיש לכם חברות בהן
- תת־קבוצות פתוחות וסגורות בעת ייצוא קבוצת האם בהרשאת ניהול של קבוצת האם, גם ללא חברות בתת־קבוצות אלה
- הפניות לקבצים ולתמונות המצורפים לתוכן הכלול בייצוא

קובץ ה־JSON המיוצא אינו כולל:

- תת־קבוצות סודיות שאין לכם חברות בהן, לרבות נתוני החברות והתוכן שלהן
- תת־קבוצות הממתינות למחיקה
- משאלים אנונימיים שטרם נסגרו
- שרשורים ומשאלים ישירים שאינם שייכים לקבוצה

בקרוב יישלח בדוא״ל קישור להורדת קובץ ה־JSON.

<!-- translation-section: print-thread-to-pdf -->

## הדפסת שרשור ל־PDF

ניתן לשמור עותק של שרשור בארכיון קבצים נפרד.

הפעולה **הדפס** שומרת את כל התגובות, המשאלים, ההצבעות והמסקנות בשרשור, יחד עם העיצוב שלו.

בתפריט השרשור יש ללחוץ על שלוש הנקודות (⋯) ולבחור **הדפס**. Loomio תיצור דף HTML שניתן להדפיס או לשמור כ־PDF באמצעות כלי ההדפסה בדפדפן.

ניתן להעתיק את הדף ולהדביק אותו בעורך מסמכים, בקובץ או במאגר נתונים.

![הפעולה הדפס בדיון על בקבוקים להחזרה](discussion_print_discussion.png#width-90)

<!-- translation-section: import-your-group-data-on-another-loomio-server -->

## ייבוא נתוני הקבוצה לשרת Loomio אחר

להוראות להקמת שרת Loomio משלכם, יש לעיין בכתובת: https://github.com/loomio/loomio

אם Loomio פועלת באירוח עצמי וברצונכם לייבא את הנתונים שיוצאו:

יש להעתיק את קובץ ה־.json לתיקיית `import` של הקונטיינר:

`scp your-group-data.json username@some-domain.org:loomio-deploy/import`

יש לפתוח את מסוף Rails הפועל:

`docker exec -ti loomio-app rails console`

יש להפעיל את השירות:

`GroupExportService.import('/import/your-group-data.json')`
