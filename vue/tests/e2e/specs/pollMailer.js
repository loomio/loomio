require('coffeescript/register')
pageHelper = require('../helpers/pageHelper.coffee')

module.exports = {
  'proposal_poll_announced': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('test_proposal_poll_created_email', { controller: 'polls' })
    page.expectText('.poll-mailer__subject', "invited you to vote on a proposal")
    page.expectText('.poll-mailer-common-summary', "You have until")
    page.expectText('.poll-mailer__vote', "Please respond")
  },

  'poll_poll_announced': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('test_poll_poll_created_email', { controller: 'polls' })
    page.expectText('.poll-mailer__subject', "invited you to vote in a poll")
    page.expectText('.poll-mailer-common-summary', "You have until")
    page.expectText('.poll-mailer__vote', "Please respond")
  },

  'count_poll_announced': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('test_count_poll_created_email', { controller: 'polls' })
    page.expectText('.poll-mailer__subject', "invited you to participate in a count")
    page.expectText('.poll-mailer-common-summary', "You have until")
    page.expectText('.poll-mailer__vote', "Please respond")
  },

  'dot_vote_poll_announced': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('test_dot_vote_poll_created_email', { controller: 'polls' })
    page.expectText('.poll-mailer__subject', "invited you to participate in a dot vote")
    page.expectText('.poll-mailer-common-summary', "You have until")
    page.expectText('.poll-mailer__vote', "Please respond")
  },

  'meeting_poll_announced': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('test_meeting_poll_created_email', { controller: 'polls' })
    page.expectText('.poll-mailer__subject', "invited you to participate in a time poll")
    page.expectText('.poll-mailer-common-summary', "You have until")
    page.expectText('.poll-mailer__vote', "Please respond")
  },

  'ranked_choice_poll_announced': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('test_ranked_choice_poll_created_email', { controller: 'polls' })
    page.expectText('.poll-mailer__subject', "invited you to rank options in a poll")
    page.expectText('.poll-mailer-common-summary', "You have until")
    page.expectText('.poll-mailer__vote', "Please respond")
  },

  'score_poll_announced': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('test_score_poll_created_email', { controller: 'polls' })
    page.expectText('.poll-mailer__subject', "invited you to vote in a score poll")
    page.expectText('.poll-mailer-common-summary', "You have until")
    page.expectText('.poll-mailer__vote', "Please respond")
  },

  'proposal_poll_edited': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('test_proposal_poll_edited_email', { controller: 'polls' })
    page.expectText('.poll-mailer__subject', "edited the proposal")
    page.expectText('.poll-mailer-common-summary', "You have until")
    page.expectText('.poll-mailer__vote', "You voted")
    page.expectText('.poll-mailer-proposal__chart', "Results")
    page.expectText('.poll-mailer-common-responses', "Responses")
  },

  'poll_poll_edited': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('test_poll_poll_edited_email', { controller: 'polls' })
    page.expectText('.poll-mailer__subject', "edited the poll")
    page.expectText('.poll-mailer-common-summary', "You have until")
    page.expectText('.poll-mailer__vote', "You voted")
    page.expectText('.poll-mailer-common-bar-chart', "Results")
    page.expectText('.poll-mailer-common-responses', "Responses")
  },

  'count_poll_edited': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('test_count_poll_edited_email', { controller: 'polls' })
    page.expectText('.poll-mailer__subject', "edited the check")
    page.expectText('.poll-mailer-common-summary', "You have until")
    page.expectText('.poll-mailer__vote', "You voted")
    page.expectText('.poll-mailer-common-bar-chart', "Results")
    page.expectText('.poll-mailer-common-responses', "Responses")
  },

  'dot_vote_poll_edited': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('test_dot_vote_poll_edited_email', { controller: 'polls' })
    page.expectText('.poll-mailer__subject', "edited the dot vote")
    page.expectText('.poll-mailer-common-summary', "You have until")
    page.expectText('.poll-mailer__vote', "You voted")
    page.expectText('.poll-mailer-common-bar-chart', "Results")
    page.expectText('.poll-mailer-common-responses', "Responses")
  },

  'meeting_poll_edited': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('test_meeting_poll_edited_email', { controller: 'polls' })
    page.expectText('.poll-mailer__subject', "edited the time poll")
    page.expectText('.poll-mailer-common-summary', "You have until")
    page.expectText('.poll-mailer__vote', "You voted")
    page.expectText('.poll-mailer__meeting-chart', "Results")
    page.expectText('.poll-mailer-common-responses', "Responses")
  },

  'ranked_choice_poll_edited': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('test_ranked_choice_poll_edited_email', { controller: 'polls' })
    page.expectText('.poll-mailer__subject', "edited the ranked choice")
    page.expectText('.poll-mailer-common-summary', "You have until")
    page.expectText('.poll-mailer__vote', "You voted")
    page.expectText('.poll-mailer-ranked-choice__chart', "Results")
    page.expectText('.poll-mailer-common-responses', "Responses")
  },

  'score_poll_edited': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('test_score_poll_edited_email', { controller: 'polls' })
    page.expectText('.poll-mailer__subject', "edited the poll")
    page.expectText('.poll-mailer-common-summary', "You have until")
    page.expectText('.poll-mailer__vote', "You voted")
    page.expectText('.poll-mailer-common-bar-chart', "Results")
    page.expectText('.poll-mailer-common-responses', "Responses")
  },

  'proposal_outcome_announced': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('test_proposal_poll_outcome_created_email', { controller: 'polls' })
    page.expectText('.poll-mailer__subject', "shared a proposal outcome")
    page.expectText('.poll-mailer-common-summary', "Outcome")
    page.expectText('.poll-mailer-proposal__chart', "Results")
    page.expectText('.poll-mailer-common-responses', "Responses")
  },

  'poll_outcome_announced': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('test_poll_poll_outcome_created_email', { controller: 'polls' })
    page.expectText('.poll-mailer__subject', "shared a poll outcome")
    page.expectText('.poll-mailer-common-summary', "Outcome")
    page.expectText('.poll-mailer-common-bar-chart', "Results")
    page.expectText('.poll-mailer-common-responses', "Responses")
  },

  'count_outcome_announced': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('test_count_poll_outcome_created_email', { controller: 'polls' })
    page.expectText('.poll-mailer__subject', "shared an outcome")
    page.expectText('.poll-mailer-common-summary', "Outcome")
    page.expectText('.poll-mailer-common-bar-chart', "Results")
    page.expectText('.poll-mailer-common-responses', "Responses")
  },

  'dot_vote_outcome_announced': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('test_dot_vote_poll_outcome_created_email', { controller: 'polls' })
    page.expectText('.poll-mailer__subject', "shared a dot vote outcome")
    page.expectText('.poll-mailer-common-summary', "Outcome")
    page.expectText('.poll-mailer-common-bar-chart', "Results")
    page.expectText('.poll-mailer-common-responses', "Responses")
  },

  'meeting_outcome_announced': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('test_meeting_poll_outcome_created_email', { controller: 'polls' })
    page.expectText('.poll-mailer__subject', "shared a time poll outcome")
    page.expectText('.poll-mailer-common-summary', "Outcome")
    page.expectText('.poll-mailer__meeting-chart', "Results")
    page.expectText('.poll-mailer-common-responses', "Responses")
  },

  'ranked_choice_outcome_announced': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('test_ranked_choice_poll_outcome_created_email', { controller: 'polls' })
    page.expectText('.poll-mailer__subject', "shared a ranked choice outcome")
    page.expectText('.poll-mailer-common-summary', "Outcome")
    page.expectText('.poll-mailer-ranked-choice__chart', "Results")
    page.expectText('.poll-mailer-common-responses', "Responses")
  },

  'score_outcome_announced': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('test_score_poll_outcome_created_email', { controller: 'polls' })
    page.expectText('.poll-mailer__subject', "shared a poll outcome")
    page.expectText('.poll-mailer-common-summary', "Outcome")
    page.expectText('.poll-mailer-common-bar-chart', "Results")
    page.expectText('.poll-mailer-common-responses', "Responses")
  },

  'proposal_stance_created': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('test_proposal_poll_stance_created_email', { controller: 'polls' })
    page.expectText('.poll-mailer__subject', "voted on")
    page.expectElement('.poll-mailer__stance')
  },

  'poll_stance_created': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('test_poll_poll_stance_created_email', { controller: 'polls' })
    page.expectText('.poll-mailer__subject', "voted on")
    page.expectElement('.poll-mailer__stance')
  },

  'count_stance_created': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('test_count_poll_stance_created_email', { controller: 'polls' })
    page.expectText('.poll-mailer__subject', "participated in")
    page.expectElement('.poll-mailer__stance')
  },

  'dot_vote_stance_created': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('test_dot_vote_poll_stance_created_email', { controller: 'polls' })
    page.expectText('.poll-mailer__subject', "voted on")
    page.expectElement('.poll-mailer__stance')
  },

  'meeting_stance_created': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('test_meeting_poll_stance_created_email', { controller: 'polls' })
    page.expectText('.poll-mailer__subject', "participated in")
    page.expectElement('.poll-mailer__stance')
  },

  // 'ranked_choice_stance_created': (test) => {
  //   // GK: the setup task fails for this for some reason; something to do with stance choices
  //   page = pageHelper(test)
  //
  //   page.loadPathNoApp('test_ranked_choice_poll_stance_created_email', { controller: 'polls' })
  //   page.expectText('.poll-mailer__subject', "voted on")
  //   page.expectElement('.poll-mailer__stance')
  // },

  'score_stance_created': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('test_score_poll_stance_created_email', { controller: 'polls' })
    page.expectText('.poll-mailer__subject', "voted on")
    page.expectElement('.poll-mailer__stance')
  },

  'proposal_poll_closing_soon': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('test_proposal_poll_closing_soon_email', { controller: 'polls' })
    page.expectText('.poll-mailer__subject', "is closing in 24 hours")
    page.expectText('.poll-mailer-common-summary', "You have until")
    page.expectText('.poll-mailer__vote', "Please respond")
  },

  'poll_poll_closing_soon': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('test_poll_poll_closing_soon_email', { controller: 'polls' })
    page.expectText('.poll-mailer__subject', "is closing in 24 hours")
    page.expectText('.poll-mailer-common-summary', "You have until")
    page.expectText('.poll-mailer__vote', "Please respond")
  },

  'count_poll_closing_soon': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('test_count_poll_closing_soon_email', { controller: 'polls' })
    page.expectText('.poll-mailer__subject', "is closing in 24 hours")
    page.expectText('.poll-mailer-common-summary', "You have until")
    page.expectText('.poll-mailer__vote', "Please respond")
  },

  'dot_vote_poll_closing_soon': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('test_dot_vote_poll_closing_soon_email', { controller: 'polls' })
    page.expectText('.poll-mailer__subject', "is closing in 24 hours")
    page.expectText('.poll-mailer-common-summary', "You have until")
    page.expectText('.poll-mailer__vote', "Please respond")
  },

  'meeting_poll_closing_soon': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('test_meeting_poll_closing_soon_email', { controller: 'polls' })
    page.expectText('.poll-mailer__subject', "is closing in 24 hours")
    page.expectText('.poll-mailer-common-summary', "You have until")
    page.expectText('.poll-mailer__vote', "Please respond")
  },

  'ranked_choice_poll_closing_soon': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('test_ranked_choice_poll_closing_soon_email', { controller: 'polls' })
    page.expectText('.poll-mailer__subject', "is closing in 24 hours")
    page.expectText('.poll-mailer-common-summary', "You have until")
    page.expectText('.poll-mailer__vote', "Please respond")
  },

  'score_poll_closing_soon': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('test_score_poll_closing_soon_email', { controller: 'polls' })
    page.expectText('.poll-mailer__subject', "is closing in 24 hours")
    page.expectText('.poll-mailer-common-summary', "You have until")
    page.expectText('.poll-mailer__vote', "Please respond")
  },

  'proposal_poll_closing_soon_author': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('test_proposal_poll_closing_soon_author_email', { controller: 'polls' })
    page.expectText('.poll-mailer__subject', "is closing in 24 hours")
    page.expectText('.poll-mailer-common-summary', "You have until")
    page.expectText('.poll-mailer__vote', "Please respond")
  },

  'poll_poll_closing_soon_author': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('test_poll_poll_closing_soon_author_email', { controller: 'polls' })
    page.expectText('.poll-mailer__subject', "is closing in 24 hours")
    page.expectText('.poll-mailer-common-summary', "You have until")
    page.expectText('.poll-mailer__vote', "Please respond")
  },

  'count_poll_closing_soon_author': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('test_count_poll_closing_soon_author_email', { controller: 'polls' })
    page.expectText('.poll-mailer__subject', "is closing in 24 hours")
    page.expectText('.poll-mailer-common-summary', "You have until")
    page.expectText('.poll-mailer__vote', "Please respond")
  },

  'dot_vote_poll_closing_soon_author': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('test_dot_vote_poll_closing_soon_author_email', { controller: 'polls' })
    page.expectText('.poll-mailer__subject', "is closing in 24 hours")
    page.expectText('.poll-mailer-common-summary', "You have until")
    page.expectText('.poll-mailer__vote', "Please respond")
  },

  'meeting_poll_closing_soon_author': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('test_meeting_poll_closing_soon_author_email', { controller: 'polls' })
    page.expectText('.poll-mailer__subject', "is closing in 24 hours")
    page.expectText('.poll-mailer-common-summary', "You have until")
    page.expectText('.poll-mailer__vote', "Please respond")
  },

  'ranked_choice_poll_closing_soon_author': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('test_ranked_choice_poll_closing_soon_author_email', { controller: 'polls' })
    page.expectText('.poll-mailer__subject', "is closing in 24 hours")
    page.expectText('.poll-mailer-common-summary', "You have until")
    page.expectText('.poll-mailer__vote', "Please respond")
  },

  'score_poll_closing_soon_author': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('test_score_poll_closing_soon_author_email', { controller: 'polls' })
    page.expectText('.poll-mailer__subject', "is closing in 24 hours")
    page.expectText('.poll-mailer-common-summary', "You have until")
    page.expectText('.poll-mailer__vote', "Please respond")
  },

  'proposal_poll_user_mentioned': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('test_proposal_poll_user_mentioned_email', { controller: 'polls' })
    page.expectText('.poll-mailer__subject', "mentioned you in")
    page.expectText('.poll-mailer-common-summary', "You have until")
    page.expectText('.poll-mailer__vote', "Please respond")
  },

  'poll_poll_user_mentioned': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('test_poll_poll_user_mentioned_email', { controller: 'polls' })
    page.expectText('.poll-mailer__subject', "mentioned you in")
    page.expectText('.poll-mailer-common-summary', "You have until")
    page.expectText('.poll-mailer__vote', "Please respond")
  },

  'count_poll_user_mentioned': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('test_count_poll_user_mentioned_email', { controller: 'polls' })
    page.expectText('.poll-mailer__subject', "mentioned you in")
    page.expectText('.poll-mailer-common-summary', "You have until")
    page.expectText('.poll-mailer__vote', "Please respond")
  },

  'dot_vote_poll_user_mentioned': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('test_dot_vote_poll_user_mentioned_email', { controller: 'polls' })
    page.expectText('.poll-mailer__subject', "mentioned you in")
    page.expectText('.poll-mailer-common-summary', "You have until")
    page.expectText('.poll-mailer__vote', "Please respond")
  },

  'meeting_poll_user_mentioned': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('test_meeting_poll_user_mentioned_email', { controller: 'polls' })
    page.expectText('.poll-mailer__subject', "mentioned you in")
    page.expectText('.poll-mailer-common-summary', "You have until")
    page.expectText('.poll-mailer__vote', "Please respond")
  },

  // 'ranked_choice_poll_user_mentioned': (test) => {
  //   page = pageHelper(test)
  //
  //   page.loadPathNoApp('test_ranked_choice_poll_user_mentioned_email', { controller: 'polls' })
  //   page.expectText('.poll-mailer__subject', "mentioned you in")
  //   page.expectText('.poll-mailer-common-summary', "You have until")
  //   page.expectText('.poll-mailer__vote', "Please respond")
  // },

  'score_poll_user_mentioned': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('test_score_poll_user_mentioned_email', { controller: 'polls' })
    page.expectText('.poll-mailer__subject', "mentioned you in")
    page.expectText('.poll-mailer-common-summary', "You have until")
    page.expectText('.poll-mailer__vote', "Please respond")
  },

  'proposal_poll_expired_author': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('test_proposal_poll_expired_author_email', { controller: 'polls' })
    page.expectText('.poll-mailer__subject', "has closed")
    page.expectElement('.poll-mailer__create_outcome')
    page.expectElement('.poll-mailer-common-summary')
    page.expectElement('.poll-mailer-common-responses')
    page.expectText('.poll-mailer-proposal__chart', "Results")
  },

  'poll_poll_expired_author': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('test_poll_poll_expired_author_email', { controller: 'polls' })
    page.expectText('.poll-mailer__subject', "has closed")
    page.expectElement('.poll-mailer__create_outcome')
    page.expectElement('.poll-mailer-common-summary')
    page.expectElement('.poll-mailer-common-responses')
    page.expectText('.poll-mailer-common-bar-chart', "Results")
  },

  'count_poll_expired_author': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('test_count_poll_expired_author_email', { controller: 'polls' })
    page.expectText('.poll-mailer__subject', "has closed")
    page.expectElement('.poll-mailer__create_outcome')
    page.expectElement('.poll-mailer-common-summary')
    page.expectElement('.poll-mailer-common-responses')
    page.expectText('.poll-mailer-common-bar-chart', "Results")
  },

  'dot_vote_poll_expired_author': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('test_dot_vote_poll_expired_author_email', { controller: 'polls' })
    page.expectText('.poll-mailer__subject', "has closed")
    page.expectElement('.poll-mailer__create_outcome')
    page.expectElement('.poll-mailer-common-summary')
    page.expectElement('.poll-mailer-common-responses')
    page.expectText('.poll-mailer-common-bar-chart', "Results")
  },

  'meeting_poll_expired_author': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('test_meeting_poll_expired_author_email', { controller: 'polls' })
    page.expectText('.poll-mailer__subject', "has closed")
    page.expectElement('.poll-mailer__create_outcome')
    page.expectElement('.poll-mailer-common-summary')
    page.expectElement('.poll-mailer-common-responses')
    page.expectText('.poll-mailer__meeting-chart', "Results")
  },

  'ranked_choice_poll_expired_author': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('test_ranked_choice_poll_expired_author_email', { controller: 'polls' })
    page.expectText('.poll-mailer__subject', "has closed")
    page.expectElement('.poll-mailer__create_outcome')
    page.expectElement('.poll-mailer-common-summary')
    page.expectElement('.poll-mailer-common-responses')
    page.expectText('.poll-mailer-ranked-choice__chart', "Results")
  },

  'score_poll_expired_author': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('test_score_poll_expired_author_email', { controller: 'polls' })
    page.expectText('.poll-mailer__subject', "has closed")
    page.expectElement('.poll-mailer__create_outcome')
    page.expectElement('.poll-mailer-common-summary')
    page.expectElement('.poll-mailer-common-responses')
    page.expectText('.poll-mailer-common-bar-chart', "Results")
  },

  'poll_poll_option_added_author': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('test_poll_poll_options_added_author_email', { controller: 'polls' })
    page.expectText('.poll-mailer__subject', "added options to")
    page.expectElement('.poll-mailer-common-option-added')
    page.expectElement('.poll-mailer__vote')
  },

  'dot_vote_poll_option_added_author': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('test_dot_vote_poll_options_added_author_email', { controller: 'polls' })
    page.expectText('.poll-mailer__subject', "added options to")
    page.expectElement('.poll-mailer-common-option-added')
    page.expectElement('.poll-mailer__vote')
  },

  'meeting_poll_option_added_author': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('test_meeting_poll_options_added_author_email', { controller: 'polls' })
    page.expectText('.poll-mailer__subject', "added options to")
    page.expectElement('.poll-mailer-common-option-added')
    page.expectElement('.poll-mailer__vote')
  },

  'ranked_choice_poll_option_added_author': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('test_ranked_choice_poll_options_added_author_email', { controller: 'polls' })
    page.expectText('.poll-mailer__subject', "added options to")
    page.expectElement('.poll-mailer-common-option-added')
    page.expectElement('.poll-mailer__vote')
  },

  'score_poll_option_added_author': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('test_score_poll_options_added_author_email', { controller: 'polls' })
    page.expectText('.poll-mailer__subject', "added options to")
    page.expectElement('.poll-mailer-common-option-added')
    page.expectElement('.poll-mailer__vote')
  },

}
