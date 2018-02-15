require('coffeescript/register')
pageHelper = require('../helpers/page_helper.coffee')

module.exports = {
  'sends default invitations to a couple of people': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_new_group')
    page.click('.members-card__invite-members-btn')
    page.fillIn('.invitation-form__email-addresses', 'Sam My <sammy@example.com>, pammy@example.com')
    page.click('.invitation-form__submit')
    page.expectText('.flash-root__message', '2 invitations sent.')
  },

  'disables send button when no valid email addresses present': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_new_group')
    page.click('.members-card__invite-members-btn')
    page.fillIn('.invitation-form__email-addresses', 'invalidemailaddress')
    page.expectElement('.invitation-form__submit[disabled]')
  },

  'allows entering email addresses to send invitations to': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_new_group')
    page.click('.members-card__invite-members-btn')
    page.fillIn('.invitation-form__email-addresses', 'dilly@example.com')
    page.click('.invitation-form__submit')
    page.expectText('.flash-root__message', 'Invitation sent.')
  },

  'has invitation link to share with the team': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_new_group')
    page.click('.members-card__invite-members-btn')
    page.expectElement('.invitation-form__shareable-link')
  },

  'displays an error if all invitees are existing group members': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_new_group')
    page.click('.members-card__invite-members-btn')
    page.fillIn('.invitation-form__email-addresses', 'patrick_swayze@example.com')
    page.click('.invitation-form__submit')
    page.expectText('.invitation-form__validation-errors', "These people are already members of the group.")
  },

  'lets you add members from the parent to a subgroup': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_group')
    page.click('.subgroups-card__start')
    page.fillIn('#group-name', 'subgroup for some')
    page.click('.group-form__submit-button')
    page.click('.members-card__invite-members-btn')
    page.click('.invitation-form__add-members')
    page.click('.add-members-modal__list-item:first-of-type')
    page.click('.add-members-modal__submit')
    page.expectText('.flash-root__message', 'Emilio Estevez added to Subgroup')
  }
}
