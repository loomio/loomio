---
title: אינטגרציות צ'אט
source_revision: ad97f553685def918a7d6e47ac5b66773de2dba8
source_file: docs/help/en/user_manual/integrations/chatbots/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-11-22'
sections:
  introduction: 46c095b75ad63f90
  what-it-looks-like-in-chat: f317dcdbffe349dc
  generate-a-webhook-url: ededdedfffbe6bcb
  set-up-a-chat-integration: d671b54fe6ae3cd1
  invite-to-poll: ffa06cde4354b243
  automatic-notifications: 21e1f83202af63e1
generated:
  introduction: 4ecbf58245e20395
  what-it-looks-like-in-chat: fbe3d2321eabfa98
  generate-a-webhook-url: 36b2bcbbf55c4c8c
  set-up-a-chat-integration: f9579316afd8e12b
  invite-to-poll: b47d8978a1fca65e
  automatic-notifications: 189039aacc77d7ae
title_source: 0eca19d30c6d7d3c
title_generated: 4ce5660f311c6e3c
---

<!-- translation-section: introduction -->

# אינטגרציות צ'אט

Loomio יכול לשלוח התראות לחדר הצ'אט.

כלי צ'אט ו־Loomio עובדים היטב יחד. ניתן להשתמש בצ'אט לשיחה מהירה ולעדכונים בזמן. כדאי להעביר נושאים חשובים ל־Loomio כשנדרש זמן להשתתפות, כשיש לקבל החלטה או כשהקבוצה זקוקה לתיעוד שיישמר לאורך זמן.

Loomio תומך ב־Slack, Discord, Microsoft Teams, Matrix ו־Mattermost.

ניתן לשלוח התראות לחדר הצ'אט באופן ידני בכל פעם שמזמינים אנשים לשרשור או לסקר. ניתן גם להגדיר התראות אוטומטיות לאירועים מסוימים, כגון פתיחת דיון.

<!-- translation-section: what-it-looks-like-in-chat -->

## כך זה נראה בצ'אט

![](chatbot_in_slack.png)

<!-- translation-section: generate-a-webhook-url -->

## חיבור שירות הצ'אט

יש לפעול לפי המדריך לשירות הצ'אט כדי לקבל כתובת Webhook (או, עבור Matrix, אסימון גישה לבוט ומזהה חדר):

- [Slack](../slack/)
- [Microsoft Teams](../microsoft_teams/)
- [Discord](../discord/)
- [Matrix](../matrix/)
- [Mattermost](../mattermost/)

ניתן לחבר גם שירותים אחרים שתומכים ב־Webhooks נכנסים בפורמט HTML או Markdown, כגון Zapier או Rocket.Chat. יש לבצע בחירה באינטגרציית הצ'אט **הכי חשוב** ב־Loomio ולהזין כתובת Webhook מותאמת אישית.

<!-- translation-section: set-up-a-chat-integration -->

## הגדרת אינטגרציית צ'אט

נדרשת הרשאה של מנהל קבוצה כדי להוסיף או לערוך אינטגרציות צ'אט.

1. לאחר הגדרת שירות הצ'אט (כמפורט למעלה), יש לפתוח את תפריט הקבוצה ב־Loomio ולבחור **אינטגרציות צ'אט**.

   ![](loomio-group-settings.png)

   ![](loomio-settings-chatbots.png)

2. יש להוסיף אינטגרציית צ'אט חדשה לשירות שנבחר, להזין שם (למשל "Discord #general") ולהדביק את כתובת ה־Webhook.

   ![](loomio-chatbot-form.png)

3. יש לבחור את האירועים שעבורם יישלחו התראות אוטומטיות, או להשאיר אותם לא מסומנים אם נדרשת רק שליחה ידנית של התראות, ולאחר מכן לשמור. ניתן לשנות הגדרות אלה בכל עת.

<!-- translation-section: invite-to-poll -->

### שליחת התראה באופן ידני

כדי לשלוח לחדר הצ'אט התראה על סקר או דיון, יש לפתוח את הפריט ולבחור **הזמן** (או פעולת התראה אחרת כגון **לשתף מסקנה**, **תזכיר להצביע** או **הסקר נערך**). יש לבחור את אינטגרציית הצ'אט מרשימת הנמענים ולשלוח את ההתראה.

![](invite_button_on_proposal.png)

![](invite_to_vote_1.png)

![](invite_to_vote_2.png)

![](chatbot_in_slack.png)

<!-- translation-section: automatic-notifications -->

### התראות אוטומטיות

כדי לשלוח התראה בכל פעם שמתרחש אירוע מסוים, יש לערוך את אינטגרציית הצ'אט ולבחור את האירוע הרצוי.

![](chatbot_enable_automatic_notifications.png)
