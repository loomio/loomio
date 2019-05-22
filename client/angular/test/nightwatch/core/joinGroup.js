require('coffeescript/register')
pageHelper = require('../helpers/page_helper')

module.exports = {
  'hides private content': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_closed_group_to_join')
    page.expectNoElement('.group-page-actions button')
    page.expectNoElement('.discussions-card__new-thread-button')
    page.expectNoElement('.members-card')
  },

  'displays public content': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_closed_group_to_join')
    page.expectText('.description-card__text', 'An FBI agent goes undercover')
    page.expectText('.thread-previews', "The name's Johnny Utah!")
    page.expectText('.subgroups-card', 'Johnny Utah')
  },

  'adds you to the group when button is clicked': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_public_group_to_join_upon_request')
    page.click('.join-group-button__join-group')
    page.expectText('.flash-root__message', 'You are now a member of')
    page.expectText('.membership-card', 'Jennifer')
  },

  'requests membership when button is clicked': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_closed_group_to_join')
    page.click('.join-group-button__ask-to-join-group')
    page.click('.membership-request-form__submit-btn')
    page.expectText('.flash-root__message', 'You have requested membership')
  },

  'can_join_closed_subgroup_when_admin_of_parent_group': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_group_with_subgroups_as_admin_landing_in_other_subgroup')
    page.click('.join-group-button__join-group')
    page.expectText('.flash-root__message', 'You are now a member of Point Break - Bodhi')
  },
}
