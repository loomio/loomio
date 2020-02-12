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

  'proposal_stance_created': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('test_proposal_poll_stance_created_email', { controller: 'polls' })
    page.expectText('.poll-mailer__subject', "voted on")
  },

  'poll_stance_created': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('test_poll_poll_stance_created_email', { controller: 'polls' })
    page.expectText('.poll-mailer__subject', "voted on")
  },

  'count_stance_created': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('test_count_poll_stance_created_email', { controller: 'polls' })
    page.expectText('.poll-mailer__subject', "voted on")
  },

  'dot_vote_stance_created': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('test_dot_vote_poll_stance_created_email', { controller: 'polls' })
    page.expectText('.poll-mailer__subject', "voted on")
  },

  'meeting_stance_created': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('test_meeting_poll_stance_created_email', { controller: 'polls' })
    page.expectText('.poll-mailer__subject', "participated in")
  },

  // 'ranked_choice_stance_created': (test) => {
  //   // GK: the setup task fails for this for some reason; something to do with stance choices
  //   page = pageHelper(test)
  //
  //   page.loadPathNoApp('test_ranked_choice_poll_stance_created_email', { controller: 'polls' })
  //   page.expectText('.poll-mailer__subject', "voted on")
  // },

  'score_stance_created': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('test_score_poll_stance_created_email', { controller: 'polls' })
    page.expectText('.poll-mailer__subject', "voted on")
  },

  'proposal_poll_closing_soon': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('test_proposal_poll_closing_soon_email', { controller: 'polls' })
    page.expectText('.poll-mailer__subject', "is closing in 24 hours")
  },

  'poll_poll_closing_soon': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('test_poll_poll_closing_soon_email', { controller: 'polls' })
    page.expectText('.poll-mailer__subject', "is closing in 24 hours")
  },

  'count_poll_closing_soon': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('test_count_poll_closing_soon_email', { controller: 'polls' })
    page.expectText('.poll-mailer__subject', "is closing in 24 hours")
  },

  'dot_vote_poll_closing_soon': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('test_dot_vote_poll_closing_soon_email', { controller: 'polls' })
    page.expectText('.poll-mailer__subject', "is closing in 24 hours")
  },

  'meeting_poll_closing_soon': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('test_meeting_poll_closing_soon_email', { controller: 'polls' })
    page.expectText('.poll-mailer__subject', "is closing in 24 hours")
  },

  'ranked_choice_poll_closing_soon': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('test_ranked_choice_poll_closing_soon_email', { controller: 'polls' })
    page.expectText('.poll-mailer__subject', "is closing in 24 hours")
  },

  'score_poll_closing_soon': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('test_score_poll_closing_soon_email', { controller: 'polls' })
    page.expectText('.poll-mailer__subject', "is closing in 24 hours")
  },

  'proposal_poll_expired_author': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('test_proposal_poll_expired_author_email', { controller: 'polls' })
    page.expectText('.poll-mailer__subject', "has closed")
  },

  'poll_poll_expired_author': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('test_poll_poll_expired_author_email', { controller: 'polls' })
    page.expectText('.poll-mailer__subject', "has closed")
  },

  'count_poll_expired_author': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('test_count_poll_expired_author_email', { controller: 'polls' })
    page.expectText('.poll-mailer__subject', "has closed")
  },

  'dot_vote_poll_expired_author': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('test_dot_vote_poll_expired_author_email', { controller: 'polls' })
    page.expectText('.poll-mailer__subject', "has closed")
  },

  'meeting_poll_expired_author': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('test_meeting_poll_expired_author_email', { controller: 'polls' })
    page.expectText('.poll-mailer__subject', "has closed")
  },

  'ranked_choice_poll_expired_author': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('test_ranked_choice_poll_expired_author_email', { controller: 'polls' })
    page.expectText('.poll-mailer__subject', "has closed")
  },

  'score_poll_expired_author': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('test_score_poll_expired_author_email', { controller: 'polls' })
    page.expectText('.poll-mailer__subject', "has closed")
  },



}
