pageHelper = require('../helpers/pageHelper')

module.exports = {
  'shows_notification_history_for_an_accepted_member': (test) => {
    const page = pageHelper(test)
    page.loadPath('setup_membership_notification_history')
    page.click('.group-page-members-tab')
    page.click('.members-panel .v-list-item:first-child .membership-dropdown__button')
    page.waitFor('.membership-dropdown__notification-history .v-list-item-title')
    page.click('.membership-dropdown__notification-history .v-list-item-title')
    page.expectText('.membership-notification-history', 'Please join the wider group discussion')
    page.expectText('.membership-notification-history', "Accepted by recipient's mail server")
    page.expectText('.membership-notification-history', 'Invitation resent')
    page.expectText('.membership-notification-history', 'No custom message')
    test.saveScreenshot('tests/screenshots/membership_notification_history.png')
    page.click('.membership-notification-history .dismiss-modal-button')
    page.expectNoElement('.membership-notification-history')
  },

  'successfully_removes_a_group_member': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_group')
    page.click('.group-page-members-tab')
    page.pause(1000);
    page.click('.members-panel .v-card .v-list .v-list-item:first-child .membership-dropdown')
    page.click('.membership-dropdown__remove')
    page.expectText('.confirm-modal', 'Remove member')
    page.click('.confirm-modal__submit')
    page.expectFlash('Member removed')
    page.expectNoText('.members-panel', 'Emilio Estevez')
  },

  // 'successfully_assigns_coordinator_privileges': (test) => {
  //   page = pageHelper(test)
  //
  //   page.loadPath('setup_group')
  //   page.click('.group-page-members-tab')
  //   page.click('.members-panel .v-card .v-list .v-list-item:first-child .membership-dropdown')
  //   page.click('.membership-dropdown__toggle-admin')
  //   page.expectFlash('Emilio Estevez is now an admin')
  // },

  'members_cannot_invite_members_by_default': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_group_as_member')
    page.click('.group-page-members-tab')
    page.expectNoElement('.membership-card__invite')
  },

  'successfully_removes_a_member': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_group_with_multiple_coordinators')
    page.click('.group-page-members-tab')
    page.click('.members-panel .v-card .v-list .v-list-item:nth-child(1) .membership-dropdown')
    page.click('.membership-dropdown__remove')
    page.click('.confirm-modal__submit')
    page.expectFlash('Member removed')
  },

  'can_remove_coordinator_privileges': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_group_with_multiple_coordinators')

    page.click('.group-page-members-tab')
    page.pause(2000)
    page.click('.members-panel .v-card .v-list .v-list-item:first-child .membership-dropdown')
    page.click('.membership-dropdown__toggle-admin')
    page.expectFlash('Emilio Estevez is no longer an admin')
  },

  // breaks on travis, unknown why
  // 'can_self_promote_when_no_coordinators': (test) => {
  //   page = pageHelper(test)
  //
  //   page.loadPath('setup_group_with_no_coordinators')
  //   page.click('.group-page-members-tab')
  //   page.click('.members-panel .v-card .v-list .v-list-item:last-child .membership-dropdown', 500)
  //   page.click('.membership-dropdown__button', 500)
  //   page.click('.membership-dropdown__toggle-admin', 500)
  //   page.expectFlash('Patrick Swayze is now an admin')
  // },

  // 'can_self_promote_when_admin_of_parent_group': (test) => {
  //   page = pageHelper(test)
  //
  //   page.loadPath('setup_group_with_subgroups_as_admin')
  //   page.click('.group-page-members-tab')
  //   page.click('.members-panel .v-card .v-list .v-list-item:first-child .membership-dropdown')
  //   page.click('.membership-dropdown__toggle-admin')
  //   page.expectFlash('Jennifer Grey is now an admin')
  // },

  'cannot_self_promote_when_coordinators': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_group_as_member')
    page.click('.group-page-members-tab')
    page.click('.membership-dropdown')
    page.expectNoText('.membership-dropdown', 'Make admin')
  },

  'can_set_membership_title': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_group')
    page.click('.group-page-members-tab')
    page.click('.members-panel .v-card .v-list .v-list-item:last-child .membership-dropdown')
    page.click('.membership-dropdown__set-title')
    page.fillIn('.membership-form__title-input input', 'Suzerain')
    page.click('.membership-form__submit')
    page.expectFlash('Membership title updated')
  },

  'can_edit_group_vote_weights': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_group_with_vote_weights')
    page.click('.group-page-members-tab')
    page.click('.members-panel__edit-weights')
    page.waitFor('.member-weights-page .v-table tbody tr')
    page.expectCount('.member-weights-page .v-table tbody tr', 3)
    page.expectText('.member-weights-page .v-table tbody tr:first-child', 'Emilio')
    page.expectText('.member-weights-page .v-table tbody tr:first-child', 'emilio@example.com')
    page.expectText('.member-weights-page .v-table tbody tr:first-child', 'Treasurer')
    page.expectText('.member-weights-page .v-table tbody tr:first-child', 'Delegate')
    page.clearField('.member-weights-page .v-table tbody tr:first-child .member-weights-page__weight-input input')
    page.fillIn('.member-weights-page .v-table tbody tr:first-child .member-weights-page__weight-input input', '2.5')
    page.click('.member-weights-page__save')
    page.expectFlash('Vote weights updated')

    page.refreshAndWait()
    page.waitFor('.member-weights-page .v-table tbody tr')
    test.expect.element('.member-weights-page .v-table tbody tr:first-child .member-weights-page__weight-input input').value.to.equal('2.5')

    page.click('.member-weights-page__set-all')
    page.waitFor('.member-weights-page__reset-dialog')
    page.clearField('.member-weights-page__reset-weight input')
    page.fillIn('.member-weights-page__reset-weight input', '0.75')
    page.click('.member-weights-page__reset-save')
    page.expectFlash('Vote weights updated')
    page.refreshAndWait()
    page.waitFor('.member-weights-page .v-table tbody tr')
    test.expect.element('.member-weights-page .v-table tbody tr:first-child .member-weights-page__weight-input input').value.to.equal('0.75')

    page.fillIn('.member-weights-page__search input', 'emilio')
    page.pause(1000)
    page.expectCount('.member-weights-page .v-table tbody tr', 1)
    page.expectText('.member-weights-page .v-table tbody tr:first-child', 'Emilio')
    page.expectText('.member-weights-page__page-count', '1–1 of 1')
  },

  // 'can_change_volume': (test) => {
  //   page = pageHelper(test)
  //
  //   page.loadPath('setup_group')
  //   page.click('.action-menu')
  //   page.click('.action-dock__button--change_volume')
  //   page.click('.volume-loud')
  //   page.click('.change-volume-form__submit')
  //   page.expectFlash('Notification settings updated')
  // }
}
