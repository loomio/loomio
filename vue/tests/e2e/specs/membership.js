pageHelper = require('../helpers/pageHelper')

module.exports = {
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
