require('coffeescript/register')
pageHelper = require('../helpers/pageHelper.coffee')

// GK: a couple of these are dependent on the poll page which we haven't done yet

module.exports = {
  // group invitation form
  'invite_to_group': (test) => {
    page = pageHelper(test)
    page.loadPath('setup_group')
    page.click('.group-page-members-tab')
    page.click('.membership-card__invite', 1000)
    page.fillIn('.announcement-form__input input', 'test@example.com')
    page.expectText('.announcement-chip__content', 'test@example.com')
    page.click('.announcement-chip__content')
    page.expectElement('.headline')
    page.click('.announcement-form__submit')
    page.expectFlash('1 notifications sent')
  },

  // discussion form
  'new_discussion': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_group')
    page.click('.discussions-panel__new-thread-button')
    page.fillIn('.announcement-form__input input', 'test@example.com')
    page.expectText('.announcement-chip__content', 'test@example.com')
    page.click('.announcement-chip__content')
    page.fillIn('.discussion-form__title-input input', 'Immannounce dis')
    // page.expectText('.discussion-form__number-notified', '4 people will be notified')
    page.click('.discussion-form__submit')
    page.expectFlash('Thread started')
    // page.expectElement('.announcement-form')
    // page.click('.announcement-form__audience')
    // page.click('.announcement-form__submit', 1000)
    // page.expectFlash('2 notifications sent')
  },

  // strand members list
  'announcement_created': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_discussion')
    page.pause(500)
    page.click('.action-dock__button--announce_thread')
    page.expectElement('.strand-members-list')
    page.pause(500)
    page.fillIn('.announcement-form__input input', 'test@example.com')
    page.expectText('.announcement-chip__content', 'test@example.com')
    page.click('.announcement-chip__content')
    page.escape()
    page.expectElement('.headline')
    page.click('.strand-members-list__submit')
    page.expectText('.strand-members-list', 'test@example.com')
    page.expectFlash('1 notifications sent')
  },

  // poll members list
  'poll_created': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_discussion')
    page.click('.activity-panel__add-proposal')
    page.fillIn('.poll-common-form-fields__title input', 'A new proposal')
    page.fillIn('.poll-common-form-fields .lmo-textarea div[contenteditable=true]', 'Some details')
    page.click('.poll-common-form__submit')
    page.expectFlash('Proposal started')
    page.pause(500)

    page.expectElement('.poll-members-list')
    page.fillIn('.announcement-form__input input', 'test@example.com')
    page.expectText('.announcement-chip__content', 'test@example.com')
    page.click('.announcement-chip__content')
    page.escape()
    page.expectElement('.headline')
    page.click('.poll-members-list__submit')
    page.expectFlash('1 notifications sent')
  },

  // 'poll_edited': (test) => {
  //   page = pageHelper(test)
  //
  //   page.loadPath('test_poll_in_discussion', { controller: 'polls' })
  //   page.click('.action-dock__button--edit_poll')
  //   page.fillIn('.poll-common-form-fields__title', 'Yo reliability, whatsup? Its me, ya boi, testing')
  //   page.click('.poll-common-form__submit')
  //   page.expectElement('.announcement-form')
  //   page.click('.announcement-form__audience')
  //   page.click('.announcement-form__submit')
  //   page.expectFlash('1 notifications sent')
  // },

  // 'outcome_created': (test) => {
  //   page = pageHelper(test)
  //
  //   page.loadPath('test_proposal_poll_closed', { controller: 'polls' })
  //   page.click('.poll-common-set-outcome-panel__submit')
  //   page.fillIn('.poll-common-outcome-form__statement textarea', 'Immannounce all yall')
  //   page.click('.poll-common-outcome-form__submit')
  //   page.expectFlash('Outcome created')
  //   page.expectElement('.announcement-form')
  //   page.selectFromAutocomplete('.announcement-form__invite input', 'test@example.com')
  //   page.expectText('.announcement-chip__content', 'test@example.com')
  //   page.click('.announcement-form__submit')
  //   page.pause(3000)
  //   page.expectFlash('1 notifications sent')
  // }
}
