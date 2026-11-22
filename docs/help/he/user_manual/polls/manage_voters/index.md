---
title: ניהול מצביעים
source_revision: ad97f553685def918a7d6e47ac5b66773de2dba8
source_file: docs/help/en/user_manual/polls/manage_voters/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-11-22'
sections:
  introduction: ea21036eb694c27f
  invite-people-to-vote-in-a-poll: e9cc8e930bcf7ef5
  invite-guests-or-experts: 8cad53202bef398e
  engage-people-while-a-poll-is-running: d0eb90b4b53003bc
  add-voters-to-the-poll: 621bd4bf8ed67895
  remove-people-from-the-poll: 1a2a5015e5c1b152
  remind-people-to-vote: baa6578549be6f09
  view-notification-history: f7f305618cb0346f
  close-early: e09d92a63b72c516
  reopen: f80ab5f17351d679
  choose-an-audience: 6cb6f0d75ded977e
  check-your-recipients: 56a7d1a92377b4ff
  send-the-invitations: f12fc1806394f916
generated:
  introduction: 390fc66afa1d6497
  invite-people-to-vote-in-a-poll: 0e155f11766c164e
  invite-guests-or-experts: b8176a49110bfe43
  engage-people-while-a-poll-is-running: d9116c09792e9370
  add-voters-to-the-poll: 2e88d91c8793c874
  remove-people-from-the-poll: 2ee51dc193fcbf7c
  remind-people-to-vote: cb16d6069cd76349
  view-notification-history: 78a28832746673d0
  close-early: f846c80be29018d5
  reopen: f213aacd66cb8790
  choose-an-audience: e8a7fe365711990e
  check-your-recipients: 1d46a9c63c756cb4
  send-the-invitations: 10163b55127c97c3
title_source: 10858faa0464257e
title_generated: 3fda8c8a6dd319a8
needs_review:
  choose-an-audience: use "בחירה" instead of "לבחור" for "Choose"
---

<!-- translation-section: introduction -->

# ניהול מצביעים

ניתן להשתמש ב**ניהול מצביעים** כדי לתת לאנשים זכות הצבעה ולהזמין אותם להשתתף בהצעה או בסקר.

<!-- translation-section: invite-people-to-vote-in-a-poll -->

<a id="invite-people-to-vote-in-a-poll"></a>
<a id="add-voters-to-the-poll"></a>

## הזמנת אנשים להצביע

לאחר פתיחת סקר עם האפשרות **אנשים נבחרים בלבד**, חלון **ניהול מצביעים** נפתח אוטומטית. ניתן לפתוח אותו גם באמצעות בחירה ב**ניהול מצביעים** בסקר.

![כפתור ניהול מצביעים בתחתית סקר](proposal_after_start.png)

<!-- translation-section: choose-an-audience -->

### בחירה בקהל

יש לבחור בשדה הריק **מצא או הזמן מצביעים** כדי לראות הצעות. הן מופיעות בסדר הבא:

- הקבוצה
- **נציגי** הקבוצה, אם יש בקבוצה [מצביעים מייצגים](/en/user_manual/groups/delegated_voters)
- חדרי צ׳אט מחוברים, כגון Slack או Microsoft Teams
- תת־קבוצות וקבוצת האם
- חברים יחידים

ב[שרשור ישיר](/en/user_manual/discussions/direct_discussions), הרשימה מציעה את האפשרות **כולם בשרשור** במקום קבוצה.

![חלון ניהול המצביעים עם הצעות לקבוצה, לנציגיה, לחדר צ׳אט ולתת־קבוצה](proposal_invite.png)

<a id="invite-a-subgroup-to-vote"></a>

יש לבחור קהל כדי להזמין את כל האנשים שבו יחד. לדוגמה, בחירה ב־**Oatmilk Cooperative** כוללת את כל האנשים בקבוצה זו. ניתן גם לבחור חדר צ׳אט מחובר כדי לפרסם בו את ההזמנה—פרסום בחדר צ׳אט אינו מוסיף את חבריו כמצביעים.

<!-- translation-section: check-your-recipients -->

### בדיקת רשימת הנמענים

לאחר בחירת קהל, השדה מציג את שמו ואת מספר האנשים הכלולים בו. יש לבדוק את המספר הזה לפני שליחת ההזמנה.

![קואופרטיב חלב שיבולת שועל נבחר, ומספר הנמענים מוצג מתחת לשדה](proposal_invite_members.png)

יש לבחור בשם הקהל כדי להרחיב אותו לרשימת אנשים. לאחר מכן ניתן לבחור בסימן **×** לצד שם כדי להסיר את האדם מההזמנה הזו. פעולה זו אינה מסירה אותו מהקבוצה.

![קהל הקבוצה מורחב לרשימת שמות, ולצד כל שם כפתור הסרה](proposal_invite_expand.png)

<!-- translation-section: invite-guests-or-experts -->

<a id="invite-guests-or-experts"></a>

### הוספת אנשים לפי שם או דוא״ל

ניתן גם להקליד שם ולבחור מתוך ההצעות, או להזין כתובת דוא״ל כדי להזמין אדם חדש. ניתן להוסיף כמה אנשים לאותה הזמנה.

![הזמנה הממוענת לחבר קבוצה ולאורח באמצעות דוא״ל, עם הודעה מוכנה לשליחה](proposal_invite_guest.png)

אורחים מקבלים גישה לסקר זה. אם הסקר נמצא בתוך שרשור, ניתן להם גם לקרוא את השרשור ואת התגובות שבו. ההזמנה אינה מעניקה הרשאה לפרסם תגובות בשרשור, להצביע בסקרים אחרים שבו או לצפות בשרשורים אחרים בקבוצה.

<!-- translation-section: send-the-invitations -->

### שליחת ההזמנות

יש להוסיף הודעה שמסבירה מה נדרשים האנשים להחליט, ואז לבחור **הזמן**. יש להשאיר את האפשרות **שלח התראות** מסומנת כדי לשלוח התראה לאנשים המוזמנים, או לבטל את הסימון כדי להוסיף מצביעים ללא שליחת התראה.

בסקר מתוזמן, יש לבחור **הוסף מצביעים**. ההזמנה תישלח עם פתיחת ההצבעה.

<!-- translation-section: engage-people-while-a-poll-is-running -->

<a id="engage-people-while-a-poll-is-running"></a>

## לאחר הזמנת אנשים

<!-- translation-section: add-voters-to-the-poll -->

### הוספת מצביעים נוספים

ניתן לפתוח שוב את **ניהול מצביעים** כדי להוסיף אנשים בכל עת, גם לפני פתיחת סקר מתוזמן. החלון מציג גם את המצביעים הקיימים, כשהאנשים שנוספו לאחרונה מופיעים ראשונים. יש להקליד שם כדי למצוא אדם מסוים, או להשתמש בכפתורי המעבר בין העמודים כדי לעיין ברשימה ארוכה יותר.

<!-- translation-section: remove-people-from-the-poll -->

### הסרת אנשים מהסקר

יש לבחור בכפתור הפח לצד שם ולאשר **הסר את הבוחר** כדי להסיר את זכות ההצבעה של אותו אדם בסקר זה. לדוגמה, בעת הגדרת הצבעה של ועד מנהל, ניתן להסיר את החשבון שמגדיר את ההצבעה אם אין לו זכות להצביע.

![חלון ניהול מצביעים המציג מצביעים קיימים, עם כפתור הפח של אחד המצביעים מודגש](proposal_invite_remove.png)

לא ניתן להסיר אנשים מסקר אנונימי. בסקרים עם [משקלי הצבעה](/en/user_manual/polls/weighted_voting), מנהלי השרשור יכולים גם לעיין במשקלים ולערוך אותם כאן.

<!-- translation-section: remind-people-to-vote -->

### שליחת תזכורת להצביע

יש לבחור **תזכורת** בסקר, לבחור את הנמענים (כגון **מי שטרם הצביעו**), להוסיף הודעה ולבחור **תזכורת** כדי לשלוח אותה.

![תזכורת הממוענת לאנשים שטרם הצביעו, עם הודעה על המועד האחרון לקבלת ההחלטה](proposal_remind.png)

<!-- translation-section: view-notification-history -->

### צפייה בהיסטוריית התראות

יש לפתוח את תפריט שלוש הנקודות (**⋯**) של הסקר ולבחור **היסטוריית התראות** כדי לראות מי הוזמנו, מתי נשלחה כל הזמנה והאם נקראה, כאשר המידע הזה זמין.

![היסטוריית התראות המציגה את נמעני ההזמנה לסקר](../../discussions/notifying_people/poll_notification_example.png)

<!-- translation-section: close-early -->

### סגירה מוקדמת

יש לבחור **סגור מוקדם** כאשר כולם כבר הצביעו או כאשר אין עוד צורך להשאיר את הסקר פתוח.

<!-- translation-section: reopen -->

### פתיחה מחדש

יש לבחור **פתח מחדש** בסקר סגור ולקבוע תאריך סגירה ושעה חדשים. לא ניתן לפתוח מחדש סקרים שמסתירים את התוצאות עד לסגירת ההצבעה, כולל סקרים אנונימיים; ניתן לדחות את מועד הסגירה שלהם כל עוד הם פתוחים.
