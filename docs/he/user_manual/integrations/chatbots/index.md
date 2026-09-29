---
title: אינטגרציות צ'אט
source_revision: 7a01b0fd7d7df0c4bca327a916b01b12e62b967f
source_file: docs/user_manual/integrations/chatbots/index.md
translated:
  provider: codex/gpt-6-sol
  'on': '2026-09-30'
sections:
  introduction: af3f509fd0a87c7d
  what-it-looks-like-in-chat: c425490496cb0ed2
  generate-a-webhook-url: a4a95bf5c61e8e3f
  set-up-a-chat-integration: d9c5b87891a0d747
  invite-to-poll: 70a0e025c79a13f0
  automatic-notifications: 381b622ece95e244
generated:
  introduction: 7e17a8518026d138
  what-it-looks-like-in-chat: d6a3d488bc3ee0dd
  generate-a-webhook-url: cac51c6198ef6c79
  set-up-a-chat-integration: 536cac204030aa0b
  invite-to-poll: c6b4de62173133b6
  automatic-notifications: d6f39b5c9a90d3bc
title_source: 0eca19d30c6d7d3c
title_generated: 4ce5660f311c6e3c
---

<!-- translation-section: introduction -->

# אינטגרציות צ'אט

Loomio יכולה לשלוח התראות לחדר הצ'אט של הקבוצה.

כלי צ'אט ו־Loomio משתלבים היטב. צ'אט מתאים לשיחות מהירות ולעדכונים שוטפים. כשנדרש זמן להשתתפות, יש לקבל החלטה או חשוב לשמור תיעוד לאורך זמן, כדאי להעביר את הנושא ל־Loomio.

Loomio תומכת ב־Slack, ב־Discord, ב־Microsoft Teams, ב־Matrix וב־Mattermost.

ניתן לשלוח התראות לחדר הצ'אט בכל עת, כפי שניתן להזמין אנשים להצביע או להצטרף לשרשור.

אפשר גם להגדיר שליחה אוטומטית של התראות כשמתרחש אירוע מסוים, למשל כשנפתח שרשור.

<!-- translation-section: what-it-looks-like-in-chat -->

## כך זה נראה בצ'אט
![](chatbot_in_slack.png)

<!-- translation-section: generate-a-webhook-url -->

## יצירת כתובת URL של Webhook
יש הוראות מפורטות לכל שירות נתמך. יש לפעול לפי ההוראות לשירות הרצוי כדי לקבל את כתובת ה־Webhook הדרושה להוספת אינטגרציית הצ'אט ב־Loomio.

- [Slack](../slack/)
- [Microsoft Teams](../microsoft_teams/)
- [Discord](../discord/)
- [Matrix](../matrix/)
- [Mattermost](../mattermost/)

אפשר להשתמש במערכת המבוססת על Webhook גם עם שירותים אחרים שתומכים ב־Webhooks נכנסים בפורמט HTML או Markdown, כגון Zapier או Rocketchat. יש לבחור בבוט של Mattermost ולהזין כתובת URL מותאמת של Webhook.

<!-- translation-section: set-up-a-chat-integration -->

## הגדרת אינטגרציית צ'אט

לאחר הגדרת השירות שנבחר (ראו למעלה), תהיה כתובת URL של Webhook. יש לפתוח את **אינטגרציות צ'אט** מתפריט הקבוצה ולהוסיף אינטגרציית צ'אט חדשה לקבוצה.

![](loomio-group-settings.png)
![](loomio-settings-chatbots.png)

בשלב זה אפשר להשאיר את תיבות הסימון ריקות. יש להזין שם (למשל "Discord #general") ואת כתובת ה־URL, וללחוץ על כפתור השמירה בתחתית הטופס.

![](loomio-chatbot-form.png)

אם בהמשך רוצים לקבל התראות אוטומטיות דרך האינטגרציה, יש לחזור להגדרות שלה ולבחור את האירועים המתאימים.

<!-- translation-section: invite-to-poll -->

### הזמנה להצביע

כך שולחים לחדר הצ'אט התראה שמזמינה אנשים להצביע על הצעה. התהליך זהה גם לשיתוף מסקנה, להזמנה לשרשור, לשליחת תזכורת להצביע, להודעה על עריכת סקר ועוד.

![](invite_button_on_proposal.png)

![](invite_to_vote_1.png)

![](invite_to_vote_2.png)

![](chatbot_in_slack.png)

<!-- translation-section: automatic-notifications -->

### התראות אוטומטיות
כדי לשלוח התראה בכל פעם שמתרחש אירוע מסוים, יש לערוך את אינטגרציית הצ'אט ולבחור באירוע הזה.

![](chatbot_enable_automatic_notifications.png)
