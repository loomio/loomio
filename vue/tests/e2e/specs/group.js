require('coffeescript/register')
pageHelper = require('../helpers/pageHelper.coffee')

module.exports = {
  'displays_parent_group_in_sidebar_if_member_of_a_subgroup': (test) => {
    page = pageHelper(test)

    page.loadPath('visit_group_as_subgroup_member')
    page.expectText('.group-cover-image', 'Point Break')
    page.expectElement('.join-group-button__ask-to-join-group')
    page.ensureSidebar()
    page.click('.sidebar-groups-menu')
    page.expectText('.sidebar__groups', 'Point Break')
  },

  'should_allow_you_to_join_an_open_group': (test) => {
    page     = pageHelper(test)

    page.loadPath('view_open_group_as_visitor')
    page.click('.join-group-button__join-group')
    page.signInViaEmail('new@account.com')
    page.click('.join-group-button__join-group')
    page.ensureSidebar()
    page.click('.sidebar-groups-menu')
    page.expectText('.sidebar__groups', 'Open Dirty Dancing Shoes')
  },

  'does_not_allow_mark_as_read_or_mute': (test) => {
    page = pageHelper(test)

    page.loadPath('view_open_group_as_visitor')
    page.expectNoElement('.thread-preview__dismiss')
    page.expectNoElement('.thread-preview__mute')
  },

  'join_an_open_group': (test) => {
    page = pageHelper(test)

    page.loadPath('view_open_group_as_non_member')
    page.click('.join-group-button__join-group')
    page.expectFlash('You are now a member')
  },

  'request_to_join_a_closed_group_group': (test) => {
    page = pageHelper(test)

    page.loadPath('view_closed_group_as_non_member')
    page.click('.join-group-button__ask-to-join-group')
    page.fillIn('.membership-request-form__introduction textarea', 'I have a reason')
    page.click('.membership-request-form__submit-btn')
    page.expectFlash('You have requested membership')
  },

  // // GK: TODO: suss the error flow
  // 'secret_group': (test) => {
  //   page = pageHelper(test)
  //
  //   page.loadPath('view_secret_group_as_non_member')
  //   page.expectElement('.error-page')
  // },

  'closed_group': (test) => {
    page = pageHelper(test)

    page.loadPath('view_closed_group_as_non_member')
    page.expectElement('.join-group-button__ask-to-join-group')
  },

  'open_group': (test) => {
    page = pageHelper(test)

    page.loadPath('view_open_group_as_non_member')
    page.expectElement('.join-group-button__join-group')
  },

  'displays_threads_from_subgroups_in_the_discussions_card': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_group_with_subgroups')
    page.click('.discussions-panel__toggle-include-subgroups label')
    page.expectText('.discussions-panel__list', 'Vaya con dios', 20000)
  },

  'starts_an_open_group': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_dashboard')
    page.ensureSidebar()
    page.click('.sidebar-groups-menu')
    page.click('.sidebar__list-item-button--start-group')
    page.click('.group-form__privacy-open')
    page.click('.group-form__advanced-link')
    page.expectElement('.group-form__joining')
    page.expectNoElement('.group-form__allow-public-threads')

    page.fillIn('#group-name', 'Open please')
    page.click('.group-form__submit-button')
    page.expectText('.group-privacy-button', 'OPEN')
  },

  'starts_a_closed_group': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_dashboard')
    page.ensureSidebar()
    page.click('.sidebar-groups-menu')
    page.click('.sidebar__list-item-button--start-group')
    page.click('.group-form__privacy-closed')
    page.click('.group-form__advanced-link')
    page.expectNoElement('.group-form__joining')
    page.expectElement('.group-form__allow-public-threads')

    page.fillIn('#group-name', 'Closed please')
    page.click('.group-form__submit-button')
    page.expectText('.group-privacy-button', 'CLOSED')
  },

  'starts_a_secret_group': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_dashboard')
    page.ensureSidebar()
    page.click('.sidebar-groups-menu')
    page.click('.sidebar__list-item-button--start-group')
    page.click('.group-form__privacy-secret')
    page.expectNoElement('.group-form__allow-public-threads', 2000)
    page.expectNoElement('.group-form__joining')

    page.click('.group-form__advanced-link')
    page.fillIn('.group-form__name input', 'Secret please')
    page.click('.group-form__submit-button')
    page.expectText('.group-privacy-button', 'SECRET')
  },

  'open_subgroup': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_open_group')
    page.click('.group-page-subgroups-tab')
    page.click('.subgroups-card__start')
    page.click('.group-form__advanced-link')
    page.click('.group-form__privacy-open')
    page.expectElement('.group-form__joining')
    page.expectNoElement('.group-form__allow-public-threads')
    page.expectNoElement('.group-form__parent-members-can-see-discussions')
  },

  'closed_subgroup': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_open_group')
    page.click('.group-page-subgroups-tab')
    page.click('.subgroups-card__start')
    page.click('.group-form__advanced-link')
    page.click('.group-form__privacy-closed')
    page.expectNoElement('.group-form__joining')
    page.expectElement('.group-form__parent-members-can-see-discussions')
    page.expectElement('.group-form__allow-public-threads')
  },

  'secret_subgroup': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_open_group')
    page.click('.group-page-subgroups-tab')
    page.click('.subgroups-card__start')
    page.click('.group-form__advanced-link')
    page.click('.group-form__privacy-secret')
    page.expectNoElement('.group-form__joining')
    page.expectNoElement('.group-form__parent-members-can-see-discussions')
    page.expectNoElement('.group-form__allow-public-threads')
  },

  'successfully_edits_group_name_and_description': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_group')
    page.click('.group-page-actions__button')
    page.click('.group-page-actions__edit-group-link')
    page.fillIn('#group-name', 'Clean Dancing Shoes')
    page.fillIn('.group-form__group-description textarea', 'Dusty sandles')
    page.click('.group-form__submit-button')
    page.expectText('.group-cover-image', 'Clean Dancing Shoes')
    page.expectText('.description-card__text', 'Dusty sandles')
  },

  // TODO reenable when clearValue bug is fixed
  // 'displays_a_validation_error_when_name_is_blank': (test) => {
  //   page = pageHelper(test)
  //
  //   page.loadPath('setup_group')
  //   page.click('.group-page-actions__button')
  //   page.click('.group-page-actions__edit-group-link')
  //   page.fillIn('.group-form__name input', '') // TODO: GK: setValue is not clearing the input
  //   page.click('.group-form__submit-button')
  //   page.pause()
  //   page.expectText('.lmo-validation-error', "can't be blank")
  // },

  'can_be_a_very_open_group': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_group')
    page.click('.group-page-actions__button')
    page.click('.group-page-actions__edit-group-link')
    page.click('.group-form__advanced-link')
    page.click('.group-form__privacy-open label')
    page.click('.group-form__membership-granted-upon-request label')
    page.click('.group-form__members-can-create-subgroups label')
    page.click('.group-form__submit-button')

    // confirm privacy change
    page.acceptConfirm()

    // reopen form
    page.click('.group-page-actions__button')
    page.click('.group-page-actions__edit-group-link')
    page.click('.group-form__advanced-link')

    // confirm the settings have stuck
    page.expectElementNow('.group-form__privacy-open input[aria-checked="true"]')
    page.expectElementNow('.group-form__membership-granted-upon-request input[aria-checked="true"]')
    page.expectElementNow('.group-form__members-can-add-members input[aria-checked="true"]')
    page.expectElementNow('.group-form__members-can-create-subgroups input[aria-checked="true"]')
  },

  'can_be_a_very_locked_down_group': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_group')
    page.click('.group-page-actions__button')
    page.click('.group-page-actions__edit-group-link')
    page.click('.group-form__advanced-link')
    page.click('.group-form__privacy-secret')
    page.click('.group-form__members-can-start-discussions label')
    page.click('.group-form__members-can-edit-discussions label')
    page.click('.group-form__members-can-edit-comments label')
    page.click('.group-form__members-can-raise-motions label')
    page.click('.group-form__members-can-vote label')
    page.click('.group-form__submit-button')

    // confirm privacy change
    page.acceptConfirm()

    // reopen form
    page.click('.group-page-actions__button')
    page.click('.group-page-actions__edit-group-link')
    page.click('.group-form__advanced-link')

    // confirm the settings have stuck
    page.expectElementNow('.group-form__privacy-secret input[aria-checked="true"]')
    page.expectNoElement('.group-form__members-can-start-discussions input[aria-checked="true"]')
    page.expectNoElement('.group-form__members-can-edit-discussions input[aria-checked="true"]')
    page.expectNoElement('.group-form__members-can-edit-comments input[aria-checked="true"]')
    page.expectNoElement('.group-form__members-can-raise-motions input[aria-checked="true"]')
    page.expectNoElement('.group-form__members-can-vote input[aria-checked="true"]')
  },

  'allows_group_members_to_leave_the_group': (test) => {
    page = pageHelper(test)

    // leave group and expect the group has left groups page
    page.loadPath('setup_group_with_multiple_coordinators')
    page.click('.group-page-actions__button')
    page.click('.group-page-actions__leave-group')
    page.click('.confirm-modal__submit')
    page.expectFlash('You have left this group')
    page.expectElement('.group-form')
  },

  'allows_a_coordinator_to_archive_a_group': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_group')
    page.click('.group-page-actions__button')
    page.click('.group-page-actions__archive-group')
    page.click('.confirm-modal__submit')
    page.expectFlash('This group has been deactivated')
    page.expectElement('.group-form')
  },

  // 'handles_empty_draft_privacy_gracefully': (test) => {
  //   page = pageHelper(test)
  //
  //   page.loadPath('setup_group_with_empty_draft')
  //   page.click('.discussions-panel__new-thread-button')
  //   page.expectText('.discussion-privacy-icon', 'The thread will only be visible')
  // },

  'successfully_starts_a_discussion': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_group')
    page.click('.discussions-panel__new-thread-button')
    page.fillIn('#discussion-title', 'Nobody puts baby in a corner')
    page.fillIn('.discussion-form .ProseMirror', "I've had the time of my life")
    page.click('.discussion-form__submit')
    page.expectFlash("Thread started")
    page.expectText('.context-panel__heading', 'Nobody puts baby in a corner' )
    page.expectText('.context-panel__description', "I've had the time of my life" )
  },

  // 'automatically_saves_drafts': (test) => {
  //   page = pageHelper(test)
  //
  //   page.loadPath('setup_group')
  //   page.click('.discussions-panel__new-thread-button')
  //   page.fillIn('.discussion-form__title-input', 'Nobody puts baby in a corner')
  //   page.fillIn('.discussion-form .ProseMirror', "I've had the time of my life")
  //   page.click('.dismiss-modal-button')
  //   page.pause()
  //   page.click('.discussions-panel__new-thread-button')
  //   page.expectValue('.discussion-form__title-input', 'Nobody puts baby in a corner' )
  //   page.expectValue('.discussion-form textarea', "I've had the time of my life" )
  // },

  'lets_you_change_membership_volume': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_group')
    page.click('.group-page-actions__button')
    page.click('.group-page-actions__change-volume-link')
    page.click('.volume-loud label')
    page.click('.change-volume-form__submit')
    page.expectFlash('You will be emailed all activity in this group.')
  },

  'lets you change the membership volume for all memberships': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_group')
    page.click('.group-page-actions__button')
    page.click('.group-page-actions__change-volume-link')
    page.click('.volume-loud label')
    page.click('.change-volume-form__apply-to-all label')
    page.click('.change-volume-form__submit')
    page.expectFlash('You will be emailed all activity in all your groups.')
  },

  // TODO: GK: think about what this test means with respect to the new UI
  // 'handles_advanced_group_settings': (test) => {
  //   page = pageHelper(test)
  //
  //   page.loadPath('setup_group_with_restrictive_settings')
  //   page.expectNoElement('.current-polls-card__start-poll')
  //   page.expectNoElement('.subgroups-card__start')
  //   page.expectNoElement('.discussions-panel__new-thread-button')
  //   page.expectNoElement('.membership-card__invite')
  //   page.pause(10000)
  //   page.click('.poll-common-preview')
  //   page.expectNoElement('.poll-common-vote-form__submit')
  // },

  'displays_emails_only_for_your_pending_invites': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_group_with_pending_invitations')
    page.click('.group-page-members-tab')
    page.fillIn('.members-panel__filter input', 'shown@test.com')
    page.expectText('.members-panel__name', 'shown@test.com')
  }
}
