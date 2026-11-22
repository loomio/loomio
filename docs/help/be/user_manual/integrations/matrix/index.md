---
title: Matrix
source_revision: ad97f553685def918a7d6e47ac5b66773de2dba8
source_file: docs/help/en/user_manual/integrations/matrix/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-11-22'
sections:
  introduction: 114ab8c916ca5fba
generated:
  introduction: ef9547e705f0bc8b
title_source: 76a2171c057b730f
title_generated: 76a2171c057b730f
---

<!-- translation-section: introduction -->

# Інтэграцыя з Matrix

Loomio можа адпраўляць апавяшчэнні ў пакой Matrix, калі з’яўляюцца новыя абмеркаванні, апытанні, каментарыі, галасы і высновы. Дадаваць інтэграцыю з чатам могуць толькі адміністратары групы.

У адрозненне ад іншых інтэграцый Loomio з чатамі, Matrix не выкарыстоўвае вэбхук. Loomio падключаецца праз уліковы запіс Matrix, які дзейнічае як бот і публікуе фарматаваныя паведамленні ў вашым пакоі.

У гэтай інструкцыі выкарыстоўваецца кліент Element.

---

1. Стварыце ўліковы запіс Matrix для Loomio, увайдзіце ў яго ў Element і запрасіце гэты ўліковы запіс у пакой Matrix, дзе вы хочаце атрымліваць апавяшчэнні. Не выходзьце з гэтага сеанса — выхад робіць маркер доступу несапраўдным.

2. У вашай групе Loomio адкрыйце меню групы, выберыце **Інтэграцыі з чатам** і дадайце інтэграцыю з чатам **Матрыца**.

   ![Меню бота Matrix у Loomio](loomio-add-matrix-bot.png)

   ![Форма бота Matrix у Loomio](loomio-matrix-bot-form.png)

3. У Element адкрыйце меню ўліковага запісу бота і выберыце **Усе налады**.

   ![Меню налад Matrix](matrix-settings-menu.png)

4. Адкрыйце **Даведка і звесткі пра праграму** і пракруціце да раздзела **Дадатковыя налады**.

   ![Налады Matrix](matrix-settings.png)

5. Скапіруйце **Маркер доступу** і ўстаўце яго ў форму Loomio.

   ![Маркер доступу Matrix](matrix-access-token.png)

6. Адкрыйце меню пакоя **Налады** і перайдзіце ў **Дадатковыя налады**.

   ![Налады пакоя Matrix](matrix-room-settings.png)

7. Скапіруйце **Унутраны ідэнтыфікатар пакоя**, устаўце яго ў форму Loomio і захавайце інтэграцыю.

   ![Ідэнтыфікатар пакоя Matrix](matrix-room-id.png)
