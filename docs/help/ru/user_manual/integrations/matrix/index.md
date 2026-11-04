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
  introduction: 7f43abbde657d605
title_source: 76a2171c057b730f
title_generated: 76a2171c057b730f
---

<!-- translation-section: introduction -->

# Интеграция с Matrix

Loomio может отправлять уведомления в ваши каналы Matrix, когда появляются новые обсуждения, предложения, комментарии, голоса и выводы.

Matrix поддерживает некоторые элементы HTML в чатах, и Loomio использует эту возможность.

Интеграция с Matrix немного отличается от других наших интеграций с чатами: она не использует вебхук. Для неё мы разработали отдельный клиент бота.

Вам нужно создать учётную запись Matrix, под которой бот будет входить в систему.

Создав учётную запись для бота, войдите под ней, чтобы получить указанные ниже данные.

В этом руководстве мы используем Element.

---

В вашей группе Loomio добавьте интеграцию с чатом Matrix
![Меню добавления бота Matrix в Loomio](loomio-add-matrix-bot.png)

Заполните эту форму
![Форма настройки бота Matrix в Loomio](loomio-matrix-bot-form.png)

Начните поиск токена доступа с этого меню
![Меню настроек Matrix](matrix-settings-menu.png)

Вот страница настроек
![Настройки Matrix](matrix-settings.png)

Вот сам токен доступа
![Токен доступа Matrix](matrix-access-token.png)

Теперь вам нужен идентификатор комнаты
![Настройки комнаты Matrix](matrix-room-settings.png)

Вот он
![Идентификатор комнаты Matrix](matrix-room-id.png)
