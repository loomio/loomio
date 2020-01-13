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
    page.loadPathNoMain('setup_saml_group?privacy=secret')
    page.pause(2000)
    page.waitForUrlToContain('saml_providers')
  },

  'should_auth_saml_viewing_closed_group_not_signed_in': (test) => {
    page = pageHelper(test)
    page.loadPathNoMain('setup_saml_group?privacy=closed')
    page.pause(2000)
    page.waitForUrlToContain('saml_providers')
  },

  'should_auth_saml_viewing_secret_group_not_member': (test) => {
    page = pageHelper(test)
    page.loadPathNoMain('setup_saml_group?sign_in=1&privacy=secret')
    page.pause(2000)
    page.waitForUrlToContain('saml_providers')
  },

  'should_pop_sign_in_modal_viewing_secret_group_pending_invitation': (test) => {
    page = pageHelper(test)
    page.loadPathNoMain('setup_saml_secret_group_pending_invitation')
    page.pause(2000)
    page.expectElement('.auth-modal')
  },

  'should_auth_saml_viewing_closed_group_not_member': (test) => {
    page = pageHelper(test)
    page.loadPathNoMain('setup_saml_group?sign_in=1&privacy=closed')
    page.pause(2000)
    page.waitForUrlToContain('saml_providers')
  },

  'should_auth_saml_viewing_secret_group_as_member': (test) => {
    page = pageHelper(test)
    page.loadPathNoMain('setup_saml_group?privacy=secret&sign_in=1&member=1')
    page.pause(2000)
    page.waitForUrlToContain('dirty-dancing-shoes')
  },

// discussion page

  'should_auth_saml_viewing_secret_group_thread_not_signed_in': (test) => {
    page = pageHelper(test)
    page.loadPathNoMain('setup_saml_group?privacy=secret&discussion=1')
    page.pause(2000)
    page.waitForUrlToContain('saml_providers')
  },

  'should_auth_saml_viewing_closed_group_thread_not_signed_in': (test) => {
    page = pageHelper(test)
    page.loadPathNoMain('setup_saml_group?privacy=closed&discussion=1')
    page.pause(2000)
    page.waitForUrlToContain('saml_providers')
  },

  'should_auth_saml_viewing_secret_group_thread_not_member': (test) => {
    page = pageHelper(test)
    page.loadPathNoMain('setup_saml_group?sign_in=1&privacy=secret&discussion=1')
    page.pause(2000)
    page.waitForUrlToContain('saml_providers')
  },

  'should_auth_saml_viewing_closed_group_thread_not_member': (test) => {
    page = pageHelper(test)
    page.loadPathNoMain('setup_saml_group?sign_in=1&privacy=closed&discussion=1')
    page.pause(2000)
    page.waitForUrlToContain('saml_providers')
  },

  'should_auth_saml_viewing_secret_group_thread_as_member': (test) => {
    page = pageHelper(test)
    page.loadPathNoMain('setup_saml_group?privacy=secret&sign_in=1&member=1&discussion=1')
    page.pause(2000)
    page.waitForUrlToContain('i-carried-a-watermelon')
  },

  'should_reauth_viewing_group_with_expired_session': (test) => {
    page = pageHelper(test)
    page.loadPathNoMain('setup_saml_group?privacy=secret&sign_in=1&member=1&expired=1')
    page.pause(2000)
    page.waitForUrlToContain('saml_providers')
  },

  'should_reauth_viewing_discussion_with_expired_session': (test) => {
    page = pageHelper(test)
    page.loadPathNoMain('setup_saml_group?privacy=secret&sign_in=1&member=1&expired=1&discussion=1')
    page.pause(5000)
    page.waitForUrlToContain('saml_providers')
  }
}
