pageHelper = require('../helpers/pageHelper')

// GK: dislaying discussions from open groups
// GK: displaying public discussions?

module.exports = {
  'hides_private_content': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_closed_group_to_join')
    page.expectNoElement('.group-page-actions button')
    page.expectNoElement('.discussions-panel__new-thread-button')
    page.click('.group-page-members-tab')
    page.expectText('.members-panel', 'You do not have permission to do this.')
  },

  'displays_public_content': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_closed_group_to_join')
    page.expectText('.group-page__description', 'An FBI agent goes undercover')
    page.expectText('.thread-previews', "The name's Johnny Utah!")
    // page.ensureSidebar()
    // page.expectText('.sidebar__groups', 'Johnny Utah')
  },

  'adds_you_to_the_group_when_button_is_clicked': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_public_group_to_join_upon_request')
    page.click('.join-group-button')
    page.expectFlash('You are now a member of')
    page.click('.group-page-members-tab')

    page.expectText('.members-panel', 'Jennifer')
  },

  'requests_membership_when_button_is_clicked': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_closed_group_to_join')
    page.click('.join-group-button')
    page.fillIn('.membership-request-form__introduction textarea', 'Hello I am a bot and id like to advertise junk to your fine membership')
    page.click('.membership-request-form__submit-btn')
    page.expectFlash('You have requested to join')
  },

  'can_join_closed_subgroup_when_admin_of_parent_group': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_group_with_subgroups_as_admin_landing_in_other_subgroup')
    page.click('.join-group-button')
    page.expectFlash('You are now a member of Point Break - Bodhi')
  },
}
