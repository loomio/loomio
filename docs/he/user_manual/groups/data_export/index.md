---
title: ייצוא נתונים
source_revision: 924e704b41670a012a16528cf88edf90f8d6b572
source_file: docs/en/user_manual/groups/data_export/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-01'
sections:
  introduction: 5e29f67f9a2084ec
  export-data: 58b5e1d4e6f0b917
  export-group-data-as-csv: 53286ec33e7300d6
  export-group-data-as-html: 101671937dcd6f36
  export-group-data-as-json: 4ec883363fb166ee
  print-thread-to-pdf: 39c48383953f9fd5
  import-your-group-data-on-another-loomio-server: 910ee8af48049e82
generated:
  introduction: 83ddee06aad14202
  export-data: 79fd9bd0f390c944
  export-group-data-as-csv: d5520f8c2057535d
  export-group-data-as-html: 87a1439b14f4c49c
  export-group-data-as-json: d7055c585deffc72
  print-thread-to-pdf: 1bfb75e4b95aaf02
  import-your-group-data-on-another-loomio-server: 3c7a3871ff8be859
title_source: 29049648f87b87f5
title_generated: 5a4d0da747307b8b
---

<!-- translation-section: introduction -->

# גיבוי או ייצוא של נתוני הקבוצה

באמצעות תכונת ייצוא נתוני הקבוצה ניתן:

- להוריד קובץ המכיל נתוני חברים כדי לבדוק את החברות בקבוצה.
- להוריד את תוכן הקבוצה, כולל הטקסט של שרשורים וסקרים, לצורך שמירה בארכיון או ניתוח.
- לפתוח תוצאות סקרים בגיליון אלקטרוני או בשפת סקריפטים.
- [להדפיס שרשור או סקר או לשמור אותם כקובצי PDF לצורך שמירה בארכיון.](#print-thread-to-pdf)
- להעביר את הקבוצה, כולל כל המשתמשים, השרשורים, הסקרים והקבצים, לשרת Loomio אחר.

ניתן להשתמש בתכונה זו כדי לעבור מהשרתים המנוהלים של Loomio [לשרת עצמאי](https://github.com/loomio/loomio).

אם שרת Loomio עצמאי מופעל ואין עוד רצון להמשיך לתחזק אותו, Loomio מציעה אירוח מנוהל בארצות הברית, באיחוד האירופי ובאוסטרליה. להעברת הקבוצה לאחד מהשרתים האלה, ניתן [ליצור איתנו קשר](/contact).

ניתן [ליצור איתנו קשר](/contact) כדי להעביר את קבוצת Loomio מהשירות העולמי של Loomio בכתובת loomio.com לאחד מהשירותים האזוריים שלנו: loomio.eu לאירופה או loomio.nz לאוסטרליה ולניו זילנד.

<!-- translation-section: export-data -->

## ייצוא נתונים

יש לפתוח את התפריט הנפתח של הקבוצה בלחיצה על שלוש הנקודות ולבחור **יצוא נתונים מהקבוצה**.

![פעולת ייצוא נתונים מהקבוצה בתפריט של קואופרטיב Oatmilk](group_export_group_data.png)

<!-- translation-section: export-group-data-as-csv -->

### ייצוא נתוני הקבוצה כקובץ CSV

*לעבודה עם נתוני הקבוצה בגיליון אלקטרוני, כגון MS Excel או Google Sheets.*

Loomio מכינה את קובץ ה־CSV ברקע ושולחת בדוא״ל קישור להורדה כשהקובץ מוכן. הקישור זמין למשך שבוע.

<!-- translation-section: export-group-data-as-html -->

### ייצוא נתוני הקבוצה כקובץ HTML

*לשמירת הנתונים בארכיון.*

Loomio מכינה את קובץ ה־HTML ברקע ושולחת בדוא״ל קישור להורדה כשהקובץ מוכן. הקישור זמין למשך שבוע.

<!-- translation-section: export-group-data-as-json -->

### ייצוא נתוני הקבוצה כקובץ JSON

*להעברת נתוני הקבוצה למופע Loomio באירוח עצמי.*

לייצוא הקבוצה נדרשות הרשאות מנהל בקבוצה. ייצוא ה־JSON כולל:

- את הקבוצה, את חבריה ואת בקשות ההצטרפות
- שרשורים, תגובות, תגובות אימוג׳י, תגיות, תבניות, התראות ורשומות קשורות מהקבוצות הכלולות בייצוא
- סקרים, אפשרויות, הצבעות ומסקנות; סקר אנונימי נכלל רק לאחר שנסגר
- תת־קבוצות שבהן קיימת חברות של החשבון המבצע את הייצוא
- תת־קבוצות פתוחות וסגורות בעת ייצוא קבוצת האם עם הרשאות מנהל בקבוצת האם, גם ללא חברות באותן תת־קבוצות
- הפניות לקבצים ולתמונות המצורפים לתוכן הכלול בייצוא

ייצוא ה־JSON אינו כולל:

- תת־קבוצות סודיות שבהן אין חברות של החשבון המבצע את הייצוא, כולל נתוני החברות והתוכן שלהן
- תת־קבוצות הממתינות למחיקה
- סקרים אנונימיים שטרם נסגרו
- שרשורים ישירים וסקרים שאינם שייכים לקבוצה

בתוך זמן קצר תישלח הודעת דוא״ל עם קישור להורדת קובץ ה־JSON.

<!-- translation-section: print-thread-to-pdf -->

## הדפסת שרשור ל־PDF

לעיתים יש צורך להפיק עותק של שרשור כדי לשמור אותו בארכיון קבצים נפרד.

הפעולה **הדפס** בשרשור שומרת את כל התגובות, הסקרים, ההצבעות והמסקנות, יחד עם עיצוב השרשור.

בתפריט השרשור יש ללחוץ על תפריט שלוש הנקודות (⋯) ולבחור **הדפס**. Loomio תיצור דף HTML שניתן להדפיס או לשמור כ־PDF באמצעות כלי ההדפסה בדפדפן.

ניתן להעתיק את הדף ולהדביק אותו בעורך מסמכים, בקובץ או במאגר נתונים.

![פעולת הדפסה בדיון על בקבוקים להחזרה](discussion_print_discussion.png#width-90)

<!-- translation-section: import-your-group-data-on-another-loomio-server -->

## ייבוא נתוני הקבוצה לשרת Loomio אחר

להוראות להגדרת שרת Loomio עצמאי, ניתן לעיין בכתובת: https://github.com/loomio/loomio

לייבוא הנתונים שיוצאו למופע Loomio באירוח עצמי:

יש להעתיק את קובץ ה־.json לתיקיית `import` של מופע הקונטיינר:

`scp your-group-data.json username@some-domain.org:loomio-deploy/import`

יש לפתוח את מסוף Rails הפעיל:

`docker exec -ti loomio-app rails console`

יש לקרוא לשירות:

`GroupExportService.import('/import/your-group-data.json')`
