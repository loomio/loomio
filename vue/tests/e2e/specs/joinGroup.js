require('coffeescript/register')
pageHelper = require('../helpers/pageHelper.coffee')

module.exports = {
  'hides_private_content': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_closed_group_to_join')
    page.expectNoElement('.group-page-actions button')
    page.expectNoElement('.discussions-panel__new-thread-button')
    page.expectNoElement('.members-card')
  },

  'displays_public_content': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_closed_group_to_join')
    page.expectText('.description-card__text', 'An FBI agent goes undercover')
    page.expectText('.thread-previews', "The name's Johnny Utah!")
    page.expectText('.subgroups-card', 'Johnny Utah')
  },

  'adds_you_to_the_group_when_button_is_clicked': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_public_group_to_join_upon_request')
    page.click('.join-group-button__join-group')
    page.expectFlash('You are now a member of')
    page.expectText('.membership-card', 'Jennifer')
  },

  'requests_membership_when_button_is_clicked': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_closed_group_to_join')
    page.click('.join-group-button__ask-to-join-group')
    page.click('.membership-request-form__submit-btn')
    page.expectFlash('You have requested membership')
  },

  'can_join_closed_subgroup_when_admin_of_parent_group': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_group_with_subgroups_as_admin_landing_in_other_subgroup')
    page.click('.join-group-button__join-group')
    page.expectFlash('You are now a member of Point Break - Bodhi')
  },
}
