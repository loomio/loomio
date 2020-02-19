require('coffeescript/register')
pageHelper = require('../helpers/pageHelper.coffee')

module.exports = {
  'discussion_announced': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('setup_discussion_mailer_discussion_announced_email')
    page.expectText('.thread-mailer__subject', "invited you to join")
    page.expectText('.thread-mailer__body', "A description for this discussion. Should this be rich?")
    page.click('.thread-mailer__subject a', 2000)
    page.expectText('.context-panel__heading', 'go to the moon')
    page.expectText('.context-panel__description', 'A description for this discussion')
    page.fillIn('.comment-form .lmo-textarea div[contenteditable=true]', 'Hello world!')
    page.click('.comment-form__submit-button')
    page.expectText('.thread-item__title', 'Jennifer Grey', 10000)
    page.expectText('.thread-item__body', 'Hello world!')
    page.expectText('.context-panel__breadcrumbs', 'Girdy Dancing Shoes')
  },

  'invitation_created': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('setup_discussion_mailer_invitation_created_email')
    page.expectText('.thread-mailer__subject', "invited you to join")
    page.expectText('.thread-mailer__body', "A description for this discussion. Should this be rich?")
    page.click('.thread-mailer__subject a', 2000)
    page.expectValue('.auth-email-form__email input', 'jen@example.com')
    page.signUpViaInvitation("Jennifer")
    page.expectFlash('Signed in successfully')
    page.expectText('.context-panel__heading', 'go to the moon', 10000)
    page.expectText('.context-panel__description', 'A description for this discussion')
    page.expectText('.new-comment__body', 'body of the comment')
  },

  'new_comment': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('setup_discussion_mailer_new_comment_email')
    page.expectText('.thread-mailer__subject', "Jennifer Grey commented in: What star sign are you?")
    page.expectText('.thread-mailer__body', "hello patrick.")
  },

  'comment_replied_to': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('setup_discussion_mailer_comment_replied_to_email')
    page.expectText('.thread-mailer__subject', "Patrick Swayze replied to you in: What star sign are you?")
    page.expectText('.thread-mailer__body', "why, hello there jen")
  },

  'user_mentioned': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('setup_discussion_mailer_user_mentioned_email')
    page.expectText('.thread-mailer__subject', "Jennifer Grey mentioned you in What star sign are you?")
    page.expectText('.thread-mailer__body', "hey @patrickswayze wanna dance?")
  },
}
