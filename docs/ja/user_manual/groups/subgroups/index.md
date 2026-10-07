---
title: サブグループ
source_revision: cd2e1e63e611688362e80009f50b8ed25025ba8b
source_file: docs/en/user_manual/groups/subgroups/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-07'
sections:
  introduction: 63e6e23d24e80919
  add-a-subgroup: 0bc0e5f99eb074c3
  subgroup-settings: 737225cc4bebe7e8
  privacy: 5bdd92ce200f197a
  permissions: ee02991523f1ebe4
  find-subgroups: 5e6fc5a5122c1417
  invite-to-a-subgroup: 0af670e1e9b32a5e
  simultaneously-invite-people-to-subgroups-and-parent-group: 1991604900321cd7
  administer-a-subgroup: 58fa95833f79dd01
  delete-a-subgroup: 2c6e76ec78386443
generated:
  introduction: d99c9be1c97d1648
  add-a-subgroup: 794946c2c597f16c
  subgroup-settings: 4d1baea010b1b7e1
  privacy: fab73faeeb6e817c
  permissions: 31d25a36be3c835d
  find-subgroups: 5711dcd4a3c90e26
  invite-to-a-subgroup: bd1058971796e58b
  simultaneously-invite-people-to-subgroups-and-parent-group: 3518924ddb8272cc
  administer-a-subgroup: 4e20b12396362d33
  delete-a-subgroup: 7bcfbcd6afa22a92
title_source: 9f81e728f70cae3e
title_generated: 70b41aa1386d23c6
---

<!-- translation-section: introduction -->

# サブグループ

サブグループを使うと、やり取りやメンバーを整理し、必要な人たちが一緒に活動できるようにします。

例えば、組織には次のようなサブグループを設けることができます。
- 理事会
- 作業チームやプロジェクトの作業グループ
- テーマ別のグループ（「戦略」や「学習」など）

サブグループはグループと同じように機能しますが、親グループの中にあります。利用できる機能や設定の大部分は親グループと同じです。また、親グループのメンバーではなくても、理事会などのサブグループのメンバーになることができます。

<!-- translation-section: add-a-subgroup -->

## サブグループを追加する

>[!Note]
>新しいサブグループを追加できるかどうかは、グループの[権限設定](/en/user_manual/groups/settings/permissions)で決まります。初期設定では、管理者のみが新しいサブグループを開始できます。

サブグループを追加するには、親グループのページを開き、サイドバーの**新しいサブグループ**をクリックします。  

![Oatmilk Cooperativeのサイドバーにある新しいサブグループボタン](subgroups-sidebar.png)

**新しいサブグループ**ボタンをクリックし、名前を入力してプライバシー設定を選択したら、**サブグループの開始**をクリックします。

![包装作業グループの新しいサブグループ作成フォーム](subgroups_new.png)

準備ができたら、サブグループに[メンバーを招待します](/en/user_manual/groups/inviting_people/)。

サブグループのページにある歯車アイコンをクリックすると、サブグループの[グループ設定](/en/user_manual/groups/settings/)を編集できます。

![包装作業グループのグループ設定を編集する操作](subgroups_edit_group_settings.png)

<!-- translation-section: subgroup-settings -->

## サブグループの設定

<!-- translation-section: privacy -->

### プライバシー

サブグループを見つけられる人と、参加方法をそれぞれ設定します。

| プライバシー | 見つけられる人 | スレッドを閲覧できる人 |
| --- | --- | --- |
| **議論中** | 誰でも | 誰でも |
| **閉鎖** | 誰でも | サブグループのメンバーと招待されたゲスト |
| **親グループに表示** | 親グループのメンバーとサブグループのメンバー | サブグループのメンバーと招待されたゲスト |
| **秘密** | 招待されたサブグループのメンバー | サブグループのメンバーと招待されたゲスト |

親グループのメンバーが自分で参加できるようにするには、サブグループの作成時、または**グループ設定を編集 → プライバシー**で、**親グループに表示**を選択し、**人々はどうやって参加するのでしょうか？**の項目で**[親グループ]のメンバーは承認なしで参加できます**を選択します。親グループに所属していない人には招待が必要です。メンバーは、親グループに所属している間は、サブグループを退会して再び参加できます。

![親グループへの表示と承認なしでの参加を設定したサブグループのプライバシー設定](subgroups_privacy_settings.png)

参加すると、通常のサブグループのメンバーになります。管理者になることはなく、既存のスレッドのプライバシーも変わりません。

公開サブグループでも、すぐに参加できるように設定できます。この設定を選択すると、誰でも参加できます。親グループが非公開の場合、サブグループで選択できる設定は**親グループに表示**と**秘密**です。

**親グループに表示**のサブグループは、親グループが公開されても非公開のままです。親グループを非公開にすると、その公開サブグループを見つけられる人は親グループのメンバーに限定され、スレッドも非公開になります。秘密のサブグループの設定は維持されます。

[グループのプライバシーについてはこちらをご覧ください](/en/user_manual/groups/settings/privacy)。

<!-- translation-section: permissions -->

### 権限

サブグループは親グループから独立して運営されます。例えば、サブグループのプライバシー設定が**秘密**の場合、招待されたメンバーのみがそのサブグループを見つけ、所属するメンバーやスレッドを閲覧できます。

**閉鎖**のサブグループと**親グループに表示**のサブグループでは、親グループのメンバーが参加前に非公開のスレッドを閲覧できるように設定できます。**権限**で**[親グループ]のメンバーは非公開のスレッドを閲覧できます**を有効にします。閲覧できるようになっても、投票権は付与されず、サブグループのメンバーにもなりません。

![親グループのメンバーがサブグループの非公開スレッドを閲覧できるようにする設定](subgroups_private_threads_settings.png)

<!-- translation-section: find-subgroups -->

## サブグループを見つける

サイドバーメニューを開き、グループ名をクリックすると、そのグループのサブグループが表示されます。

![サイドバーに表示されたOatmilk Cooperativeのサブグループ](subgroups_find_subgroups.png)

<!-- translation-section: invite-to-a-subgroup -->

## サブグループに招待する

グループに招待するときと同じ方法で、サブグループに招待できます。招待する人が、招待を送る人も所属している同じ組織の親グループや別のサブグループにすでに所属している場合は、名前を入力するか、そのグループを招待先として選択できます。招待先のチップを選択すると、個々の人の一覧に展開されます。その後、招待しない人を一覧から削除します。

<!-- translation-section: simultaneously-invite-people-to-subgroups-and-parent-group -->

### サブグループと親グループに同時に招待する

親グループの**メンバー**タブにある**メンバーを招待する**ボタンを使うと、すぐに参加してもらいたいサブグループのチェックボックスを選択して、複数のサブグループに同時に招待できます。

![招待フォームで親グループとサブグループを選択する画面](group_invite_email_subgroups.png)

<!-- translation-section: administer-a-subgroup -->

## サブグループを管理する

サブグループには独自の管理者を設定できます。サブグループの管理者は、親グループの管理者と同じである必要はありません。

ただし、親グループの管理者は、どのサブグループでも自分を管理者に設定できます。これにより、親グループの管理者は必要に応じてサブグループを管理できます。

サブグループタブを開き、対象のサブグループを見つけて、**グループに参加する**をクリックします。

![閉鎖のサブグループにあるグループに参加するボタン](member_join_subgroup.png)

サブグループのメンバーになった親グループの管理者は、自分をサブグループの管理者に設定できます。

![親グループの管理者が自分を管理者に設定する操作](member_make_admin.png)

<!-- translation-section: delete-a-subgroup -->

## サブグループを削除する

管理者は、グループを削除するときと同じ方法でサブグループを削除できます。サブグループを削除する際は、親グループを削除しないように注意してください。

[グループの削除方法](/en/user_manual/groups/deleting_your_group/)をご覧ください。
