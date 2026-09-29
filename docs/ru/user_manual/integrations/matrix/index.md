---
title: Matrix
source_revision: 7a01b0fd7d7df0c4bca327a916b01b12e62b967f
source_file: docs/user_manual/integrations/matrix/index.md
translated:
  provider: codex/gpt-6-sol
  'on': '2026-09-30'
sections:
  introduction: e54de0b6d9ea9ffb
generated:
  introduction: b30004f03e410c7b
title_source: 76a2171c057b730f
title_generated: 76a2171c057b730f
---

<!-- translation-section: introduction -->

# Интеграция с Matrix

Loomio может отправлять уведомления в ваши каналы Matrix о новых обсуждениях, предложениях, комментариях, голосах и итогах.

Matrix поддерживает некоторые HTML-теги в чате, и Loomio использует эту возможность.

Интеграция с Matrix устроена иначе, чем другие интеграции Loomio с чатами: вместо вебхука она использует специально созданного бота.

Создайте пользователя Matrix, от имени которого бот будет входить в систему.

После этого войдите в учётную запись бота, чтобы получить данные, указанные ниже.

В этом руководстве используется Element.

---

Добавьте интеграцию с чатом Matrix в вашей группе Loomio
![меню добавления бота Matrix в Loomio](loomio-add-matrix-bot.png)

Заполните эту форму
![форма настройки бота Matrix в Loomio](loomio-matrix-bot-form.png)

Чтобы найти токен доступа, откройте это меню
![меню настроек Matrix](matrix-settings-menu.png)

Откроется страница настроек
![настройки Matrix](matrix-settings.png)

Здесь находится токен доступа
![токен доступа Matrix](matrix-access-token.png)

Теперь найдите идентификатор комнаты
![настройки комнаты Matrix](matrix-room-settings.png)

Идентификатор комнаты находится здесь.
![идентификатор комнаты Matrix](matrix-room-id.png)
