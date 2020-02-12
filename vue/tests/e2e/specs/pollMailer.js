require('coffeescript/register')
pageHelper = require('../helpers/pageHelper.coffee')

module.exports = {
  '@disabled': true,

  'proposal_poll_announced': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('test_proposal_poll_created_email', { controller: 'polls' })
    page.expectText('.poll-mailer__subject', "invited you to vote on a proposal")
  },

  'poll_poll_announced': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('test_poll_poll_created_email', { controller: 'polls' })
    page.expectText('.poll-mailer__subject', "invited you to vote in a poll")
  },

  'count_poll_announced': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('test_count_poll_created_email', { controller: 'polls' })
    page.expectText('.poll-mailer__subject', "invited you to participate in a count")
  },

  'dot_vote_poll_announced': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('test_dot_vote_poll_created_email', { controller: 'polls' })
    page.expectText('.poll-mailer__subject', "invited you to participate in a dot vote")
  },

  'meeting_poll_announced': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('test_meeting_poll_created_email', { controller: 'polls' })
    page.expectText('.poll-mailer__subject', "invited you to participate in a time poll")
  },

  'ranked_choice_poll_announced': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('test_ranked_choice_poll_created_email', { controller: 'polls' })
    page.expectText('.poll-mailer__subject', "invited you to rank options in a poll")
  },

  'score_poll_announced': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('test_score_poll_created_email', { controller: 'polls' })
    page.expectText('.poll-mailer__subject', "invited you to vote in a score poll")
  },

}
