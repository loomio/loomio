---
title: אינטגרציות צ'אט
source_revision: 924e704b41670a012a16528cf88edf90f8d6b572
source_file: docs/en/user_manual/integrations/chatbots/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-01'
sections:
  introduction: af3f509fd0a87c7d
  what-it-looks-like-in-chat: c425490496cb0ed2
  generate-a-webhook-url: a4a95bf5c61e8e3f
  set-up-a-chat-integration: d9c5b87891a0d747
  invite-to-poll: 70a0e025c79a13f0
  automatic-notifications: 381b622ece95e244
generated:
  introduction: a3ee06c442ce43c7
  what-it-looks-like-in-chat: d6a3d488bc3ee0dd
  generate-a-webhook-url: 57ce202354eadfb5
  set-up-a-chat-integration: c4d7a26b40b1d678
  invite-to-poll: 7128ac98c9588848
  automatic-notifications: 5e276eaa536d1f1a
title_source: 0eca19d30c6d7d3c
title_generated: 4ce5660f311c6e3c
---

<!-- translation-section: introduction -->

# אינטגרציות צ'אט

Loomio יכול לשלוח התראות לחדר הצ'אט.

כלי צ'אט ו־Loomio עובדים היטב יחד. ניתן להשתמש בצ'אט לשיחה מהירה ולעדכונים בזמן. כדאי להעביר נושאים חשובים ל־Loomio כשנדרש זמן להשתתפות, כשיש לקבל החלטה או כשהקבוצה זקוקה לתיעוד שיישמר לאורך זמן.

Loomio תומך ב־Slack, Discord, Microsoft Teams, Matrix ו־Mattermost.

ניתן לשלוח התראות לחדר הצ'אט בכל עת, באותו אופן שבו מזמינים אנשים להצביע או להצטרף לשרשור.

ניתן גם להגדיר שליחה אוטומטית של התראות בכל פעם שמתרחש אירוע מסוים, למשל פתיחת שרשור.

<!-- translation-section: what-it-looks-like-in-chat -->

## כך זה נראה בצ'אט
![](chatbot_in_slack.png)

<!-- translation-section: generate-a-webhook-url -->

## יצירת כתובת Webhook
הכנו מדריכים שלב אחר שלב לכל שירות נתמך. יש לפעול לפי המדריך המתאים לשירות שנבחר כדי לקבל את כתובת ה־Webhook הנדרשת להוספת אינטגרציית הצ'אט ב־Loomio.

- [Slack](../slack/)
- [Microsoft Teams](../microsoft_teams/)
- [Discord](../discord/)
- [Matrix](../matrix/)
- [Mattermost](../mattermost/)

המערכת שלנו מבוססת על Webhook וניתן להשתמש בה גם עם מערכות אחרות שתומכות ב־Webhooks נכנסים בפורמט HTML או Markdown, כגון Zapier או Rocketchat. יש לבחור בבוט של Mattermost ולהשתמש בכתובת Webhook מותאמת אישית.

<!-- translation-section: set-up-a-chat-integration -->

## הגדרת אינטגרציית צ'אט

לאחר הגדרת השירות שנבחר (ראו למעלה), תתקבל כתובת Webhook. יש לפתוח את **אינטגרציות צ'אט** מתפריט הקבוצה ולהוסיף אינטגרציית צ'אט חדשה לקבוצה.

![](loomio-group-settings.png)
![](loomio-settings-chatbots.png)

בשלב זה ניתן להשאיר את כל תיבות הסימון לא מסומנות. יש להזין את השם (למשל "Discord #general") ואת הכתובת וללחוץ על כפתור השמירה בתחתית הטופס.

![](loomio-chatbot-form.png)

אם בהמשך יהיה צורך בהתראות אוטומטיות דרך האינטגרציה, ניתן לחזור להגדרות שלה ולבחור את האירועים הרלוונטיים.

<!-- translation-section: invite-to-poll -->

### הזמנה לסקר

כך ניתן לשלוח לחדר הצ'אט התראה המזמינה אנשים להצביע בהצעה. אותו תהליך משמש גם לשיתוף מסקנה, להזמנה לשרשור, לתזכורת להצביע, להתראה על עריכת סקר וכדומה.

![](invite_button_on_proposal.png)

![](invite_to_vote_1.png)

![](invite_to_vote_2.png)

![](chatbot_in_slack.png)

<!-- translation-section: automatic-notifications -->

### התראות אוטומטיות
כדי לשלוח התראה בכל פעם שמתרחש אירוע מסוים, יש לערוך את אינטגרציית הצ'אט ולבחור את האירוע הרצוי.

![](chatbot_enable_automatic_notifications.png)
