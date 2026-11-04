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
  introduction: 2a96ba4ca011f3c4
title_source: 76a2171c057b730f
title_generated: 76a2171c057b730f
---

<!-- translation-section: introduction -->

# Інтэграцыя з Matrix

Loomio можа адпраўляць апавяшчэнні ў вашы каналы Matrix, калі з’яўляюцца новыя абмеркаванні, прапановы, каментарыі, галасы і высновы.

Matrix дазваляе выкарыстоўваць некаторыя элементы HTML у пакоі чата, і Loomio выкарыстоўвае гэтую магчымасць.

Наша інтэграцыя з Matrix крыху адрозніваецца ад іншых інтэграцый з чатамі: яна не выкарыстоўвае вэбхук. Для яе мы стварылі асобны кліент бота.

Вам трэба стварыць уліковы запіс Matrix, праз які бот будзе ўваходзіць у сістэму.

Пасля стварэння ўліковага запісу для бота ўвайдзіце ў яго, каб атрымаць наступныя звесткі.

У гэтай інструкцыі мы выкарыстоўваем Element.

---

У вашай групе Loomio дадайце інтэграцыю з чатам Matrix
![Меню бота Matrix у Loomio](loomio-add-matrix-bot.png)

Вось форма, якую трэба запоўніць
![Форма бота Matrix у Loomio](loomio-matrix-bot-form.png)

Пачніце тут, каб знайсці ваш токен доступу
![Меню налад Matrix](matrix-settings-menu.png)

Вось старонка налад
![Налады Matrix](matrix-settings.png)

Вось сам токен доступу
![Токен доступу Matrix](matrix-access-token.png)

Цяпер вам патрэбны ідэнтыфікатар пакоя
![Налады пакоя Matrix](matrix-room-settings.png)

Вось ён.
![Ідэнтыфікатар пакоя Matrix](matrix-room-id.png)
