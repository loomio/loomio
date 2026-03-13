pageHelper = require('../helpers/pageHelper')

module.exports = {
  'test_stv_vote_form_renders': (test) => {
    page = pageHelper(test)

    page.loadPath('polls/test_poll_scenario?scenario=poll_created&poll_type=stv')
    page.expectElement('.poll-stv-vote-form')
  }
}
