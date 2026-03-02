pageHelper = require('../helpers/pageHelper')

module.exports = {
  'test_stv_divider_shown_on_new_vote': (test) => {
    page = pageHelper(test)

    page.loadPath('polls/test_poll_scenario?scenario=poll_created&poll_type=stv')
    page.expectElement('.poll-stv-vote-form__divider')
    // All items should be below divider (unranked) for a new vote
    page.expectNoElement('.poll-stv-vote-form__option:not(.poll-stv-vote-form__option--unranked)')
    // Submit with 0 ranked items — should be accepted
    page.click('.poll-common-vote-form__submit')
    page.expectText('.flash-root__message', 'Vote recorded')
  },

  'test_stv_divider_shows_ranked_items_on_edit': (test) => {
    page = pageHelper(test)

    page.loadPath('polls/test_poll_scenario?scenario=stv_vote_cast')
    page.expectElement('.poll-stv-vote-form__divider')
    // Ranked items appear above divider (no --unranked class)
    page.expectElement('.poll-stv-vote-form__option:not(.poll-stv-vote-form__option--unranked)')
    // Unranked items appear below divider
    page.expectElement('.poll-stv-vote-form__option--unranked')
  }
}
