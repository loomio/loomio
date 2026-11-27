---
title: ייצוא נתונים
source_revision: 6e7aad6a91a50e55dca43a20edcc88d445ee4185
source_file: docs/help/en/user_manual/groups/data_export/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-11-26'
sections:
  introduction: 988679ffd3d29834
  export-data: '024783a0614721d2'
  export-group-data-as-csv: c0845f09bff828f2
  export-group-data-as-html: 659fd5e14956b00e
  export-group-data-as-json: 4c2131f4518b7469
  print-thread-to-pdf: 1a1d0598f4277ba1
  import-your-group-data-on-another-loomio-server: 33d49c6c25be163b
generated:
  introduction: 8e1092202c539901
  export-data: 226034ffbdc22a5e
  export-group-data-as-csv: 8e5bcfb3c7a05aae
  export-group-data-as-html: 3c2dbd4320aed4d7
  export-group-data-as-json: 6c071868648f0fe7
  print-thread-to-pdf: 5042322f5b32a98c
  import-your-group-data-on-another-loomio-server: fd21c288c0671154
title_source: 29049648f87b87f5
title_generated: 5a4d0da747307b8b
---

<!-- translation-section: introduction -->

# גיבוי או ייצוא של נתוני הקבוצה

באמצעות ייצוא נתוני הקבוצה ניתן:

- להוריד נתוני חברים כדי לבדוק את החברות בקבוצה.
- לשמור בארכיון או לנתח את השרשורים, התגובות והסקרים של הקבוצה.
- לפתוח תוצאות סקרים בגיליון אלקטרוני או בסקריפט.
- [להדפיס שרשור או סקר או לשמור אותם כקובצי PDF לצורכי תיעוד.](#print-thread-to-pdf)
- להעביר את הקבוצה, כולל המשתמשים, השרשורים, הסקרים והקבצים שלה, לשרת Loomio אחר.

ניתן להשתמש בתכונה זו כדי לעבור משירות האירוח של Loomio ל[שרת באירוח עצמי](https://github.com/loomio/loomio). למעבר משרת עצמאי לאירוח המנוהל של Loomio בארצות הברית, באיחוד האירופי או באוסטרליה, ניתן [ליצור איתנו קשר](/contact).

ניתן [ליצור איתנו קשר](/contact) כדי להעביר קבוצה מ־loomio.com לשירות אזורי (loomio.eu לאירופה או loomio.nz לאוסטרליה ולניו זילנד).

<!-- translation-section: export-data -->

## ייצוא נתונים

לייצוא נתוני הקבוצה נדרשות הרשאות מנהל בקבוצה. יש לפתוח את **הגדרות** בעמוד הקבוצה ולבחור **יצוא נתונים מהקבוצה**.

![פעולת ייצוא נתונים מהקבוצה בעמוד ההגדרות של קואופרטיב Oatmilk](group_export_group_data.png)

Loomio מכינה את הייצוא ברקע ושולחת בדוא״ל קישור להורדה כשהוא מוכן. הקישור נשאר פעיל למשך שבוע.

<!-- translation-section: export-group-data-as-csv -->

### ייצוא נתוני הקבוצה כקובץ CSV

ניתן להשתמש ב־CSV כדי לבדוק את נתוני הקבוצה, כולל פרטי חברים ופעילותם, בגיליון אלקטרוני כגון Microsoft Excel או Google Sheets.

<!-- translation-section: export-group-data-as-html -->

### ייצוא נתוני הקבוצה כקובץ HTML

ניתן להשתמש ב־HTML כדי לשמור עותק קריא של הדיונים והסקרים של הקבוצה לצורך שמירה בארכיון.

<!-- translation-section: export-group-data-as-json -->

### ייצוא נתוני הקבוצה כקובץ JSON

ניתן להשתמש ב־JSON כדי להעביר את נתוני הקבוצה לשרת Loomio באירוח עצמי.

ייצוא ה־JSON כולל:

- את הקבוצה, את חבריה ואת בקשות ההצטרפות
- שרשורים, תגובות, תגובות אימוג׳י, תגיות, תבניות, התראות ורשומות קשורות מהקבוצות הכלולות בייצוא
- סקרים, אפשרויות, הצבעות ומסקנות; סקר אנונימי נכלל רק לאחר שנסגר
- תת־קבוצות שבהן קיימת חברות של החשבון המבצע את הייצוא
- תת־קבוצות פתוחות, סגורות וגלויות לקבוצת האם בעת ייצוא קבוצת האם עם הרשאות מנהל בקבוצת האם, גם ללא חברות באותן תת־קבוצות
- הפניות לקבצים ולתמונות המצורפים לתוכן הכלול בייצוא

ייצוא ה־JSON אינו כולל:

- תת־קבוצות סודיות שבהן אין חברות של החשבון המבצע את הייצוא, כולל נתוני החברות והתוכן שלהן
- תת־קבוצות הממתינות למחיקה
- סקרים אנונימיים שטרם נסגרו
- שרשורים ישירים וסקרים שאינם שייכים לקבוצה

<!-- translation-section: print-thread-to-pdf -->

## הדפסת שרשור ל־PDF

כדי לשמור שרשור יחיד לצורכי תיעוד, יש לפתוח את תפריט הפעולות שלו ולבחור **הדפס**. Loomio יוצרת דף HTML הכולל את התגובות, הסקרים, ההצבעות, המסקנות והעיצוב של השרשור. ניתן להשתמש בכלי ההדפסה של הדפדפן כדי להדפיס את הדף או לשמור אותו כ־PDF, או להעתיק את התוכן למסמך אחר.

![פעולת הדפסה בדיון על בקבוקים להחזרה](discussion_print_discussion.png#width-90)

<!-- translation-section: import-your-group-data-on-another-loomio-server -->

## ייבוא נתוני הקבוצה לשרת Loomio אחר

סעיף זה מיועד לניהול שרת Loomio באירוח עצמי. להוראות התקנה, ניתן לעיין ב[מאגר הקוד של Loomio](https://github.com/loomio/loomio).

1. יש להעתיק את קובץ ה־`.json` לתיקיית `import` של הקונטיינר:

```sh
scp your-group-data.json username@some-domain.org:loomio-deploy/import
```

2. יש לפתוח את מסוף Rails בקונטיינר הפעיל:

```sh
docker exec -ti loomio-app rails console
```

3. יש להפעיל את שירות הייבוא:

```ruby
GroupExportService.import('/import/your-group-data.json')
```
