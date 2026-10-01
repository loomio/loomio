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
  introduction: 987f5ab1803426db
title_source: 76a2171c057b730f
title_generated: 76a2171c057b730f
---

<!-- translation-section: introduction -->

# Інтеграція з Matrix

Loomio може надсилати сповіщення у ваші канали Matrix, коли з’являються нові обговорення, пропозиції, коментарі, голоси та висновки.

Matrix підтримує деякі HTML-теги в кімнатах чату, і Loomio використовує цю можливість.

Наша інтеграція з Matrix дещо відрізняється від інших інтеграцій із чатами: вона не використовує вебхук. Для неї ми створили власний клієнт бота.

Вам потрібно створити обліковий запис у Matrix, під яким бот входитиме в систему.

Створивши обліковий запис для бота, увійдіть під ним, щоб отримати наведені нижче дані.

У цьому посібнику ми використовуємо Element.

---

У вашій групі Loomio додайте інтеграцію з чатом Matrix
![меню додавання бота Matrix у Loomio](loomio-add-matrix-bot.png)

Ось форма, яку потрібно заповнити
![форма налаштування бота Matrix у Loomio](loomio-matrix-bot-form.png)

Тут можна почати пошук вашого токена доступу
![меню налаштувань Matrix](matrix-settings-menu.png)

Ось сторінка налаштувань
![налаштування Matrix](matrix-settings.png)

Ось сам токен доступу
![токен доступу Matrix](matrix-access-token.png)

Тепер вам потрібен ідентифікатор кімнати
![налаштування кімнати Matrix](matrix-room-settings.png)

Ось він.
![ідентифікатор кімнати Matrix](matrix-room-id.png)
