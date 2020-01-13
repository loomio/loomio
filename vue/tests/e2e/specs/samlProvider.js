require('coffeescript/register')
pageHelper = require('../helpers/pageHelper.coffee')

module.exports = {

  //
  // group with saml provider
  //   secret group not signed in
  //   secret group not a member
  //   closed group not signed in
  //   closed group not a member

  //
  // discussion.group with saml provider
  //   private discussion not a member
  //   public discussion

  'should_auth_saml_viewing_secret_group_not_signed_in': (test) => {
    page = pageHelper(test)
    page.loadPath('setup_saml_secret_group_not_signed_in')
    page.pause(2000)
    page.waitForUrlToContain('saml_providers')
  },

  'should_auth_saml_viewing_closed_group_not_signed_in': (test) => {
    page = pageHelper(test)
    page.loadPath('setup_saml_closed_group_not_signed_in')
    page.pause(2000)
    page.waitForUrlToContain('saml_providers')
  },

  'should_auth_saml_viewing_secret_group_not_member': (test) => {
    page = pageHelper(test)
    page.loadPath('setup_saml_secret_group_not_member')
    page.pause(2000)
    page.waitForUrlToContain('saml_providers')
  },

  'should_pop_sign_in_modal_viewing_secret_group_pending_invitation': (test) => {
    page = pageHelper(test)
    page.loadPath('setup_saml_secret_group_pending_invitation')
    page.pause(2000)
    page.expectElement('.auth-modal')
  },

  'should_auth_saml_viewing_closed_group_not_member': (test) => {
    page = pageHelper(test)
    page.loadPath('setup_saml_closed_group_not_member')
    page.pause(2000)
    page.waitForUrlToContain('saml_providers')
  },

  'should_auth_saml_viewing_secret_group_as_member': (test) => {
    page = pageHelper(test)
    page.loadPath('setup_saml_secret_group_as_member')
    page.pause(2000)
    page.waitForUrlToContain('secret-shoes')
  },
}
