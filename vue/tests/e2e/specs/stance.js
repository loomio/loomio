format = require('date-fns/format')
require('coffeescript/register')
pageHelper = require('../helpers/pageHelper.coffee')

module.exports = {
  'can_vote_on_a_proposal_as_group_member': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('polls/test_invite_to_poll')
    page.click('.thread-mailer__subject a', 1000)
    # login
    # vote
  }
  'can_vote_on_a_proposal_as_guest': (test) => {
  }
}
