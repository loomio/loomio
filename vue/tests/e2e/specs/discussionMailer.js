require('coffeescript/register')
pageHelper = require('../helpers/pageHelper.coffee')

module.exports = {
  'invites_a_user_to_a_discussion': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('setup_discussion_mailer_new_discussion_email')
    page.click('.thread-mailer__subject a', 2000)
    page.expectText('.context-panel__heading', 'go to the moon')
    page.expectText('.context-panel__description', 'A description for this discussion')
    page.fillIn('.comment-form .lmo-textarea div[contenteditable=true]', 'Hello world!')
    page.click('.comment-form__submit-button')
    page.expectText('.thread-item__title', 'Jennifer Grey', 10000)
    page.expectText('.thread-item__body', 'Hello world!')
    page.expectText('.context-panel__breadcrumbs', 'Girdy Dancing Shoes')
  },

  'invites_an_email_to_a_discussion': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('setup_discussion_mailer_invitation_created_email')
    page.click('.thread-mailer__subject a', 2000)
    page.expectValue('.auth-email-form__email input', 'jen@example.com')
    page.signUpViaInvitation("Jennifer")
    page.expectFlash('Signed in successfully')
    page.expectText('.context-panel__heading', 'go to the moon', 10000)
    page.expectText('.context-panel__description', 'A description for this discussion')
    page.expectText('.new-comment__body', 'body of the comment')
  },
}
