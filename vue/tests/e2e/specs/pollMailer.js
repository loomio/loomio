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

  'proposal_poll_edited': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('test_proposal_poll_edited_email', { controller: 'polls' })
    page.expectText('.poll-mailer__subject', "edited the proposal")
  },

  'poll_poll_edited': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('test_poll_poll_edited_email', { controller: 'polls' })
    page.expectText('.poll-mailer__subject', "edited the poll")
  },

  'count_poll_edited': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('test_count_poll_edited_email', { controller: 'polls' })
    page.expectText('.poll-mailer__subject', "edited the check")
  },

  'dot_vote_poll_edited': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('test_dot_vote_poll_edited_email', { controller: 'polls' })
    page.expectText('.poll-mailer__subject', "edited the dot vote")
  },

  'meeting_poll_edited': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('test_meeting_poll_edited_email', { controller: 'polls' })
    page.expectText('.poll-mailer__subject', "edited the time poll")
  },

  'ranked_choice_poll_edited': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('test_ranked_choice_poll_edited_email', { controller: 'polls' })
    page.expectText('.poll-mailer__subject', "edited the ranked choice")
  },

  'score_poll_edited': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('test_score_poll_edited_email', { controller: 'polls' })
    page.expectText('.poll-mailer__subject', "edited the score poll")
  },

  'proposal_outcome_announced': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('test_proposal_poll_outcome_created_email', { controller: 'polls' })
    page.expectText('.poll-mailer__subject', "shared a proposal outcome")
  },

  'poll_outcome_announced': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('test_poll_poll_outcome_created_email', { controller: 'polls' })
    page.expectText('.poll-mailer__subject', "shared a poll outcome")
  },

  'count_outcome_announced': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('test_count_poll_outcome_created_email', { controller: 'polls' })
    page.expectText('.poll-mailer__subject', "shared an outcome")
  },

  'dot_vote_outcome_announced': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('test_dot_vote_poll_outcome_created_email', { controller: 'polls' })
    page.expectText('.poll-mailer__subject', "shared a dot vote outcome")
  },

  'meeting_outcome_announced': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('test_meeting_poll_outcome_created_email', { controller: 'polls' })
    page.expectText('.poll-mailer__subject', "shared a time poll outcome")
  },

  'ranked_choice_outcome_announced': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('test_ranked_choice_poll_outcome_created_email', { controller: 'polls' })
    page.expectText('.poll-mailer__subject', "shared a ranked choice outcome")
  },

  'score_outcome_announced': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('test_score_poll_outcome_created_email', { controller: 'polls' })
    page.expectText('.poll-mailer__subject', "shared a poll outcome")
  },



}
