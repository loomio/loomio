require('coffeescript/register')
pageHelper = require('../helpers/pageHelper.coffee')

module.exports = {
  'proposal_poll_announced': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('test_proposal_poll_created_email', { controller: 'polls' })
    page.expectText('.thread-mailer__subject', "Patrick Swayze invited you to vote on a proposal")
  },

}
