require('coffeescript/register')
pageHelper     = require('../helpers/page_helper.coffee')
workflowHelper = require('../helpers/workflow_helper.coffee')

module.exports = {
  'displays parent group in sidebar if member of a subgroup': (test) => {
    page = pageHelper(test)

    page.loadPath('visit_group_as_subgroup_member')
    page.expectText('.group-theme__name', 'Point Break')
    page.expectElement('.join-group-button__ask-to-join-group')
    page.ensureSidebar()
    page.expectElement('.sidebar__list-item--selected')
  },

  'should allow you to join an open group': (test) => {
    page     = pageHelper(test)
    workflow = workflowHelper(test)

    page.loadPath('view_open_group_as_visitor')
    page.click('.join-group-button__join-group')
    workflow.signInViaEmail('new@account.com')
    page.click('.join-group-button__join-group')
    page.ensureSidebar()
    page.expectElement('.sidebar__content')
    page.expectText('.group-theme__name', 'Open Dirty Dancing Shoes')
  },

  'does not allow mark as read or mute': (test) => {
    page = pageHelper(test)

    page.loadPath('view_open_group_as_visitor')
    page.expectNoElement('.thread-preview__dismiss')
    page.expectNoElement('.thread-preview__mute')
  },

  'join an open group': (test) => {
    page = pageHelper(test)

    page.loadPath('view_open_group_as_non_member')
    page.click('.join-group-button__join-group')
    page.expectText('.flash-root__message', 'You are now a member')
  },

  'request to join a closed group group': (test) => {
    page = pageHelper(test)

    page.loadPath('view_closed_group_as_non_member')
    page.click('.join-group-button__ask-to-join-group')
    page.fillIn('.membership-request-form__introduction', 'I have a reason')
    page.click('.membership-request-form__submit-btn')
    page.expectText('.flash-root__message', 'You have requested membership')
  },

  'secret group': (test) => {
    page = pageHelper(test)

    page.loadPath('view_secret_group_as_non_member')
    page.expectElement('.error-page')
  },

  'closed group': (test) => {
    page = pageHelper(test)

    page.loadPath('view_closed_group_as_non_member')
    page.expectElement('.join-group-button__ask-to-join-group')
  },

  'open group': (test) => {
    page = pageHelper(test)

    page.loadPath('view_open_group_as_non_member')
    page.expectElement('.join-group-button__join-group')
  },

  'displays threads from subgroups in the discussions card': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_group_with_subgroups')
    page.expectText('.discussions-card__list', 'Vaya con dios')
  },

  'starts an open group': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_dashboard')
    page.ensureSidebar()
    page.click('.sidebar__list-item-button--start-group')
    page.click('.group-form__privacy-open')
    page.click('.group-form__advanced-link')

    page.expectElement('.group-form__joining')
    page.expectNoElement('.group-form__allow-public-threads')

    page.fillIn('#group-name', 'Open please')
    page.click('.group-form__submit-button')
    page.expectText('.group-privacy-button', 'OPEN')
  },

  'starts a closed group': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_dashboard')
    page.ensureSidebar()
    page.click('.sidebar__list-item-button--start-group')
    page.click('.group-form__privacy-closed')
    page.click('.group-form__advanced-link')

    page.expectNoElement('.group-form__joining')
    page.expectElement('.group-form__allow-public-threads')

    page.fillIn('#group-name', 'Closed please')
    page.click('.group-form__submit-button')
    page.expectText('.group-privacy-button', 'CLOSED')
  },

  'starts a secret group': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_dashboard')
    page.ensureSidebar()
    page.click('.sidebar__list-item-button--start-group')
    page.click('.group-form__privacy-secret')
    page.click('.group-form__advanced-link')

    page.expectNoElement('.group-form__joining')
    page.expectNoElement('.group-form__allow-public-threads')

    page.fillIn('#group-name', 'Secret please')
    page.click('.group-form__submit-button')
    page.expectText('.group-privacy-button', 'SECRET')
  },

  'open subgroup': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_open_group')
    page.click('.subgroups-card__start')
    page.click('.group-form__advanced-link')
    page.click('.group-form__privacy-open')
    page.expectElement('.group-form__joining')
    page.expectNoElement('.group-form__allow-public-threads')
    page.expectNoElement('.group-form__parent-members-can-see-discussions')
  },

  'closed subgroup': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_open_group')
    page.click('.subgroups-card__start')
    page.click('.group-form__advanced-link')
    page.click('.group-form__privacy-closed')
    page.expectNoElement('.group-form__joining')
    page.expectElement('.group-form__parent-members-can-see-discussions')
    page.expectElement('.group-form__allow-public-threads')
  },

  'secret subgroup': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_open_group')
    page.click('.subgroups-card__start')
    page.click('.group-form__advanced-link')
    page.click('.group-form__privacy-secret')
    page.expectNoElement('.group-form__joining')
    page.expectNoElement('.group-form__parent-members-can-see-discussions')
    page.expectNoElement('.group-form__allow-public-threads')
  },

  'open subgroup': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_closed_group')
    page.click('.subgroups-card__start')
    page.click('.group-form__advanced-link')
    page.click('.group-form__privacy-open')
    page.expectElement('.group-form__joining')
    page.expectNoElement('.group-form__allow-public-threads')
    page.expectNoElement('.group-form__parent-members-can-see-discussions')
  },

  'closed subgroup': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_closed_group')
    page.click('.subgroups-card__start')
    page.click('.group-form__advanced-link')
    page.click('.group-form__privacy-closed')
    page.expectNoElement('.group-form__joining')
    page.expectElement('.group-form__parent-members-can-see-discussions')
    page.expectElement('.group-form__allow-public-threads')
  },

  'secret subgroup': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_closed_group')
    page.click('.subgroups-card__start')
    page.click('.group-form__advanced-link')
    page.click('.group-form__privacy-secret')
    page.expectNoElement('.group-form__joining')
    page.expectNoElement('.group-form__parent-members-can-see-discussions')
    page.expectNoElement('.group-form__allow-public-threads')
  },

  'open subgroup': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_secret_group')
    page.click('.subgroups-card__start')
    page.click('.group-form__advanced-link')
    page.expectNoElement('.group-form__privacy-open')
  },

  'closed subgroup': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_secret_group')
    page.click('.subgroups-card__start')
    page.click('.group-form__advanced-link')
    page.click('.group-form__privacy-closed')
    page.expectText('.group-form__privacy', 'Members of Secret Dirty Dancing Shoes can find this subgroup and ask to join. All threads are private. Only members can see who is in the group.')
    page.expectNoElement('.group-form__joining')
    page.expectElement('.group-form__parent-members-can-see-discussions')
    page.expectNoElement('.group-form__allow-public-threads')
  },

  'secret subgroup': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_secret_group')
    page.click('.subgroups-card__start')
    page.click('.group-form__advanced-link')
    page.click('.group-form__privacy-secret')
    page.expectNoElement('.group-form__joining')
    page.expectNoElement('.group-form__parent-members-can-see-discussions')
    page.expectNoElement('.group-form__allow-public-threads')
  },

  'successfully edits group name and description': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_group')
    page.click('.group-page-actions__button')
    page.click('.group-page-actions__edit-group-link')
    page.fillIn('#group-name', 'Clean Dancing Shoes')
    page.fillIn('.group-form .lmo-textarea textarea', 'Dusty sandles')
    page.click('.group-form__submit-button')
    page.expectText('.group-theme__name', 'Clean Dancing Shoes')
    page.expectText('.description-card__text', 'Dusty sandles')
  },

  'displays a validation error when name is blank': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_group')
    page.click('.group-page-actions__button')
    page.click('.group-page-actions__edit-group-link')
    page.fillIn('#group-name', '')
    page.click('.group-form__submit-button')
    page.expectText('.lmo-validation-error', "can't be blank")
  },

  'can be a very open group': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_group')
    page.click('.group-page-actions__button')
    page.click('.group-page-actions__edit-group-link')
    page.click('.group-form__advanced-link')
    page.click('.group-form__privacy-open')
    page.click('.group-form__membership-granted-upon-request')
    page.click('.group-form__members-can-create-subgroups')
    page.click('.group-form__submit-button')

    // confirm privacy change
    page.acceptConfirm()

    // reopen form
    page.click('.group-page-actions__button')
    page.click('.group-page-actions__edit-group-link')
    page.click('.group-form__advanced-link')

    // confirm the settings have stuck
    page.expectElement('.group-form__privacy-open.md-checked')
    page.expectElement('.group-form__membership-granted-upon-request.md-checked')
    page.expectElement('.group-form__members-can-add-members .md-checked')
    page.expectElement('.group-form__members-can-create-subgroups .md-checked')
  },

  'can be a very locked down group': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_group')
    page.click('.group-page-actions__button')
    page.click('.group-page-actions__edit-group-link')
    page.click('.group-form__advanced-link')
    page.click('.group-form__privacy-secret')
    page.click('.group-form__members-can-start-discussions')
    page.click('.group-form__members-can-edit-discussions')
    page.click('.group-form__members-can-edit-comments')
    page.click('.group-form__members-can-raise-motions')
    page.click('.group-form__members-can-vote')
    page.click('.group-form__submit-button')

    // confirm privacy change
    page.acceptConfirm()

    // reopen form
    page.click('.group-page-actions__button')
    page.click('.group-page-actions__edit-group-link')
    page.click('.group-form__advanced-link')

    // confirm the settings have stuck
    page.expectElement('.group-form__privacy-secret.md-checked')
    page.expectNoElement('.group-form__members-can-start-discussions .md-checked')
    page.expectNoElement('.group-form__members-can-edit-discussions .md-checked')
    page.expectNoElement('.group-form__members-can-edit-comments .md-checked')
    page.expectNoElement('.group-form__members-can-raise-motions .md-checked')
    page.expectNoElement('.group-form__members-can-vote .md-checked')
  },

  'allows group members to leave the group': (test) => {
    page = pageHelper(test)

    // leave group and expect the group has left groups page
    page.loadPath('setup_group_with_multiple_coordinators')
    page.click('.group-page-actions__button')
    page.click('.group-page-actions__leave-group')
    page.click('.leave-group-form__submit')
    page.expectText('.flash-root__message', 'You have left this group')
    page.expectText('.dashboard-page__no-groups', "Start or join a group to see threads")
  },

  'prevents last coordinator from leaving the group': (test) => {
    page = pageHelper(test)

    // click(leave group from the group actions downdown)
    // see that we can't leave until we add a coordinator
    // click(add coordinator and check we're taken to the memberships page)
    page.loadPath('setup_group')
    page.click('.group-page-actions__button')
    page.click('.group-page-actions__leave-group')
    page.expectText('.leave-group-form', 'You cannot leave this group')
  },

  'allows a coordinator to archive a group': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_group')
    page.click('.group-page-actions__button')
    page.click('.group-page-actions__archive-group')
    page.click('.archive-group-form__submit')
    page.expectText('.flash-root__message', 'This group has been deactivated')
    page.expectText('.dashboard-page__no-groups', "Start or join a group to see threads")
  },

  'handles empty draft privacy gracefully': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_group_with_empty_draft')
    page.click('.discussions-card__new-thread-button')
    page.expectText('.discussion-privacy-icon', 'The thread will only be visible')
  },

  'successfully starts a discussion': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_group')
    page.click('.discussions-card__new-thread-button')
    page.fillIn('#discussion-title', 'Nobody puts baby in a corner')
    page.fillIn('.discussion-form textarea', "I've had the time of my life")
    page.click('.discussion-form__submit')
    page.expectText('.flash-root__message',('Thread started'))
    page.expectText('.context-panel__heading', 'Nobody puts baby in a corner' )
    page.expectText('.context-panel__description', "I've had the time of my life" )
  },

  'automatically saves drafts': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_group')
    page.click('.discussions-card__new-thread-button')
    page.fillIn('.discussion-form__title-input', 'Nobody puts baby in a corner')
    page.fillIn('.discussion-form textarea', "I've had the time of my life")
    page.click('.modal-cancel')
    page.click('.discussions-card__new-thread-button')
    page.expectValue('#discussion-title', 'Nobody puts baby in a corner' )
    page.expectValue('.discussion-form textarea', "I've had the time of my life" )
  },

  'lets you change membership volume': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_group')
    page.click('.group-page-actions__button')
    page.click('.group-page-actions__change-volume-link')
    page.click('#volume-loud')
    page.click('.change-volume-form__submit')
    page.expectText('.flash-root__message', 'You will be emailed all activity in this group.')
  },

  'lets you change the membership volume for all memberships': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_group')
    page.click('.group-page-actions__button')
    page.click('.group-page-actions__change-volume-link')
    page.click('#volume-loud')
    page.click('.change-volume-form__apply-to-all')
    page.click('.change-volume-form__submit')
    page.expectText('.flash-root__message', 'You will be emailed all activity in all your groups.')
  },

  'handles subdomain redirects': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_group_with_subdomain')
    page.expectText('.group-theme__name', 'Ghostbusters')
  },

  'handles advanced group settings': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_group_with_restrictive_settings')
    page.expectNoElement('.current-polls-card__start-poll')
    page.expectNoElement('.subgroups-card__start')
    page.expectNoElement('.discussions-card__new-thread-button')
    page.expectNoElement('.members-card__invite-members')
    page.click('.poll-common-preview')
    page.expectNoElement('.poll-common-vote-form__submit')
  }

}
